extends Camera3D

# Sensitivity of the mouse movement
var mouse_sensitivity: float = 0.1
var move_speed: float = 15.0
var is_paused:bool=false

var grabbed_object =null
var ray_cast:RayCast3D
var grab_distance:float=0.0

# Track the vertical rotation
var vertical_rotation: float = 0.0

func _ready():
	# Hide the mouse cursor and capture it
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	ray_cast=$RayCast3D
	

func _process(delta):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if grabbed_object==null:
			#try to grab obj
			var collider=ray_cast.get_collider()
			if collider!=null: 
				print("colider not null")
				if collider.is_in_group("grabbable"):
					grabbed_object=collider
					grab_distance=(grabbed_object.global_transform.origin-global_transform.origin).length()
					var target_pos=global_transform.origin+global_transform.basis.z*-1*grab_distance
					grabbed_object.global_transform.origin=target_pos
		if grabbed_object!=null:
			grab_distance=(grabbed_object.global_transform.origin-global_transform.origin).length()
			var target_pos=global_transform.origin+global_transform.basis.z*-1*grab_distance
			grabbed_object.global_transform.origin=target_pos
			'''
			ray_cast.force_raycast_update()
			if ray_cast.is_colliding():
				print("COLLISION DETECED")
				var collider=ray_cast.get_collider()
				if collider.is_in_group("grabbable"):
					grabbed_object=collider
					print("IM GRABBING AN OBJECT")
					#find and store distance to keep object in same disance
					#will change this later to move obj closer/further using mouse scroll
					grab_distance=(grabbed_object.global_transform.origin-global_transform.origin).length()
				
		if grabbed_object:
			#move the object in front of camera
			var target_pos=global_transform.origin+global_transform.basis.z*grab_distance
			grabbed_object.global_transform.origin=target_pos'''
	else:
		if grabbed_object:
			#release obj if button isnt pressed
			grabbed_object=null
			
func _on_Area3D_body_entered(body):
	#this func will be called when collision occurs
	print("collision")
	
	# Handle upward and downward movemen
func _input(event):
	if is_paused:
		return
		
	if event is InputEventMouseMotion:
		# Calculate new rotations based on mouse movement
		var mouse_delta = event.relative

		# Horizontal rotation (yaw)
		rotate_y(deg_to_rad(-mouse_delta.x * mouse_sensitivity))

		# Vertical rotation (pitch)
		vertical_rotation -= mouse_delta.y * mouse_sensitivity

		# Clamp the vertical rotation to avoid flipping
		vertical_rotation = clamp(vertical_rotation, -90, 90)
		rotation_degrees.x = vertical_rotation

	
func set_paused_state(paused: bool) -> void:
	is_paused = paused
