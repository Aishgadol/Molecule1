extends Node3D

var script_path:String
var script_path_global:String
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	script_path = "res://gc.py"
	script_path_global = ProjectSettings.globalize_path(script_path)
	if !FileAccess.file_exists(script_path_global):
		push_error("Python script 'gc.py' not found at path: %s" % script_path_global)
	else:
		print("Python script 'gc.py' found at path: %s" % script_path_global)
	
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func open_zmatrix_file() -> String:
	var file_dialog = FileDialog.new()
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.filters = ["*.csv", "*.txt", "*.zmat"]
	add_child(file_dialog)
	file_dialog.popup_centered()

	await file_dialog.wait_for_signal("file_selected")
	var file_path = file_dialog.get_current_path()
	if file_path:
		var content = load_file_content(file_path)
		if content != null and is_valid_zmatrix(content):
			return content
		else:
			print("Invalid Z-matrix format.")
			return ""
	else:
		print("No file selected.")
		return ""

func load_file_content(file_path: String) -> String:
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file !=null:
		var content = file.get_as_text()
		file.close()
		return content
	else:
		return ""

func is_valid_zmatrix(content: String) -> bool:
	var lines = content.strip_edges().split("\n", false)
	var line_count = 0
	for line in lines:
		line = line.strip_edges()
		if line == "":
			continue  # Skip empty lines
		var tokens = line.split()
		line_count += 1
		if line_count == 1:
			# First line should have one token
			if tokens.size() != 1:
				return false
		elif line_count == 2:
			# Second line should have three tokens
			if tokens.size() != 3:
				return false
		elif line_count == 3:
			# Third line should have five tokens
			if tokens.size() != 5:
				return false
		else:
			# Subsequent lines should have seven tokens
			if tokens.size() != 7:
				return false
	return true
	
func convert_zmatrix_to_coordinates(z_matrix_string: String) -> Array:
	var coordinates = []
	var zmat_file_path = "user://temp_zmat.zmat"  # Changed to user:// for export compatibility

	# Write the Z-matrix string to a temporary file using FileAccess
	var zmat_file = FileAccess.open(zmat_file_path, FileAccess.WRITE)
	if zmat_file == null:
		push_error("Failed to write Z-matrix to temporary file.")
		return coordinates
	zmat_file.store_string(z_matrix_string)
	zmat_file.close()

	# Get absolute paths
	var zmat_file_global = ProjectSettings.globalize_path(zmat_file_path)
	var script_path = ProjectSettings.globalize_path("res://gc.py")
	var python_executable = "python"  # Update this if Python is not in your PATH

	# Debugging: Print the paths and arguments to verify
	print("Z-matrix file path:", zmat_file_global)
	print("Python script path:", script_path)
	
	# Prepare arguments for the Python script
	var args = PackedStringArray([script_path, "-zmat", zmat_file_global])
	print("Arguments passed to Python:", args)

	# Run the Python script using OS.execute()
	var output = []
	var exit_code = OS.execute(python_executable, args, output, true)  # 'true' to capture stderr
	
	# Check for errors during execution
	if exit_code != 0:
		push_error("Python script execution failed with exit code: %d" % exit_code)
		for x in output:
			push_error("Error output: %s" % (x + "\n"))
		return coordinates
	
	# Get the output from the process
	var stdout:String=""
	for i in range(output.size()):
		output[i]+="\n"
		stdout+=output[i]
	#var stdout:String = String(output)
	var lines = stdout.strip_edges().split("\n")
	#for l in lines:
		#print( l )  # Debug print to see each line
	
	if lines.size() < 3:
		push_error("Invalid output from Python script.")
		return coordinates

	var num_atoms = int(lines[0])
	var title_line = lines[1]
	
	if lines.size() < num_atoms + 2:
		push_error("Incomplete atom data in output.")
		return coordinates

	# Extract atom coordinates
	for i in range(2, 2 + num_atoms):
		var line = lines[i].strip_edges()
		
		if line == "":
			print("Line is empty, skipping...")
			continue
		
		line = line.replace("\t", " ")  # Replace tabs with spaces
		line = line.replace("\r", " ")  # Replace carriage returns with spaces
		line = line.replace("  ", " ")  # Ensure multiple spaces are reduced to one
		
		# Split the cleaned line
		var tokens = line.split(" ", false)  # Split by single spaces
		
		if tokens.size() != 4:
			push_error("Invalid atom line: %s" % line)
			continue
		
		var symbol = tokens[0]
		var z = float(tokens[1])
		var x = float(tokens[2])
		var y = float(tokens[3])
		#print("Adding atom: symbol=%s, x=%f, y=%f, z=%f" % [symbol, x, y, z])  # Debug print
		
		coordinates.append({
			"symbol": symbol,
			"position": Vector3(x, y, z),
		})

	# Clean up temporary files
	var dir = DirAccess.open("user://")  # Ensure user:// is being used
	if dir:
		dir.remove("temp_zmat.zmat")
	
	return coordinates


func convert_coordinates_to_zmatrix(cartesian_string: String) -> String:
	var zmat_string = ""
	var xyz_file_path = "user://temp_xyz.xyz"  # Path to store the Cartesian coordinates

	# Clean the input string to ensure proper formatting
	cartesian_string = cartesian_string.replace("\t", " ")  # Replace tabs with spaces
	cartesian_string = cartesian_string.replace("\r", " ")  # Replace carriage returns with spaces
	while cartesian_string.find("  ") != -1:  # Replace multiple spaces with a single space
		cartesian_string = cartesian_string.replace("  ", " ")
	
	# Write the cleaned Cartesian string to a temporary XYZ file using FileAccess
	var xyz_file = FileAccess.open(xyz_file_path, FileAccess.WRITE)
	if xyz_file == null:
		push_error("Failed to write Cartesian coordinates to temporary file.")
		print("file null")
		return zmat_string
	xyz_file.store_string(cartesian_string)
	xyz_file.close()

	# Get absolute paths
	var xyz_file_global = ProjectSettings.globalize_path(xyz_file_path)
	var script_path = ProjectSettings.globalize_path("res://gc.py")
	var python_executable = "python"  # Update this if Python is not in your PATH

	# Prepare arguments for the Python script to convert XYZ to Z-matrix
	var args = PackedStringArray([script_path, "-xyz", xyz_file_global])
	print("Arguments passed to Python:", args)

	# Run the Python script using OS.execute()
	var output = []
	var exit_code = OS.execute(python_executable, args, output, true)  # 'true' to capture stderr

	# Check for errors during execution
	if exit_code < 0:
		push_error("Python script execution failed with exit code: %d" % exit_code)
		print("exitcode")
		for x in output:
			push_error("Error output: %s" % (x + "\n"))
		return zmat_string

	# Get the output from the process
	var stdout:String = ""
	for i in range(output.size()):
		stdout += output[i] + "\n"
	
	# The output is expected to be the Z-matrix
	zmat_string = stdout.strip_edges()

	# Clean up temporary files
	var dir = DirAccess.open("user://")
	if dir:
		dir.remove("temp_xyz.xyz")

	return zmat_string
