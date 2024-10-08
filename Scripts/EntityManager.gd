class_name EntityManager
extends Node

@onready var root:Node3D=$Root

#  |    |  |  |    |
#  \/  \/ \/  \/   \/
var zmat_molecules = [] #zmat: string
var xyz_molecules=[] #xyz: dict: {"xyz":str , "bonds":[ [atom_i,atom_j] , [atom_k,atom_m] ...]}
# ^^^^ these two might not be necesary cuz if mol changes, they need to change too,
# too much work updating for every little change :(

var displayed_molecules=[] #displayable items for world display
var mol_counter:int=0
# Called when the node enters the scene tree for the first time.

#auxilary methods for constructing the 3d node for molecule
func parse_xyz(xyz_string:String)->Array:
	var lines=xyz_string.strip_edges().split("\n")
	var num_atoms=int(lines[0])
	var atoms=[]
	for i in range(2,2+num_atoms):
		var parts=lines[i].strip_edges().split()
		if parts.size() >=4:
			var symbol=parts[0]
			var x=float(parts[1])
			var y=float(parts[2])
			var z=float(parts[3])
			var atom={"symbol":symbol,"position":Vector3(x,y,z)}
			atoms.append(atom)
	return atoms

func get_atom_mesh() ->Mesh:
	var mesh=SphereMesh.new()
	mesh.radius=2.0
	mesh.height=4.0
	return mesh
	
func get_atom_aura_mesh()->Mesh:
	var mesh=SphereMesh.new()
	mesh.radius=2.0*1.2
	mesh.height=4.0*1.2
	return mesh
	
func get_aura_material() -> StandardMaterial3D:
	var mat=StandardMaterial3D.new()
	mat.albedo_color=Color(1,1,1,0.5)
	#mat.transparency_mode=BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.cull_mode=BaseMaterial3D.CULL_FRONT
	return mat
	
func get_tube_mesh(l :float)->Mesh:
	var mesh=CylinderMesh.new()
	mesh.top_radius=get_tube_radius()
	mesh.bottom_radius=get_tube_radius()
	mesh.height=l
	return mesh
	
func get_tube_radius()->float:
	return 0.5
	
func get_tube_aura_mesh(l:float)->Mesh:
	var mesh=CylinderMesh.new()
	var radius=get_tube_radius()*1.2
	mesh.top_radius=radius
	mesh.bottom_radius=radius
	mesh.height=l
	return mesh
	
func get_tube_transform(pos1:Vector3,pos2:Vector3)->Transform3D:
	var dir=pos2-pos1
	var l=dir.length()
	var mid=(pos1+pos2)*0.5
	var up=Vector3(0,1,0)
	var axis=up.cross(dir).normalized()
	var angle=acos(up.dot(dir.normalized()))
	var basis=Basis()
	
	if axis.length()==0:
		if dir.y>0:
			basis=Basis()
		else:
			basis=Basis(Vector3(1,0,0),PI)
	else:
		basis=Basis(axis,angle)
	
	var transform=Transform3D(basis,mid)
	return transform
	
#end of auxilary methods



func _ready() -> void:
	

	print("good morning from entity maanger")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	

	
#mol: { "zmat":zmat_string (string) , "xyz": xyz_string (string), "bonds":bonds (array) }
func newMol(mol):
	var mol_node:Node3D=buildMol(mol)
	displayed_molecules.append(mol_node)
	root.spawn_molecule(mol_node)
	
	for x in mol:
		print(x," :\n",mol[x])
		
		

func buildMol(mol_data: Dictionary) -> Node3D:
	var mol:Node3D=Node3D.new()
	mol.name="mol_"+str(mol_counter)
	mol.add_to_group("grabbable")
	
	var molbody=RigidBody3D.new()
	molbody.gravity_scale=0
	molbody.name="molbody_"+str(mol_counter)
	mol.add_child(molbody)
	
	var atoms = parse_xyz(mol_data["xyz"])
	
	var bonds=mol_data["bonds"]
	
	#create aura
	var aura_node=Node3D.new()
	aura_node.name="aura"
	aura_node.visible=false
	molbody.add_child(aura_node)
	
	#create atom nodes
	for i in range(len(atoms)):
		var atom=atoms[i]
		var symbol=atom["symbol"]
		var pos=atom["position"]
		
		var atom_mesh=MeshInstance3D.new()
		atom_mesh.name="atom{0}_mesh".format([i+1])
		atom_mesh.transform.origin=pos
		atom_mesh.mesh=get_atom_mesh()
		molbody.add_child(atom_mesh)
		
		var atom_label=Label3D.new()
		atom_label.name="atom{0}_label".format([i+1])
		atom_label.text=symbol
		#atom_label.BillboardMode
		atom_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
		atom_label.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
		atom_label.transform.origin=pos
		molbody.add_child(atom_label)
		
		#collisionshape for atom
		var atom_col=CollisionShape3D.new()
		atom_col.name="atom{0}_collision".format([i+1])
		atom_col.transform.origin=pos
		var sphere_shape=SphereShape3D.new()
		sphere_shape.radius=2.0
		#sphere_shape.height=4.0
		atom_col.shape=sphere_shape
		molbody.add_child(atom_col)
		
		#create aura for atom
		var atom_aura=MeshInstance3D.new()
		atom_aura.name="atom{0}_aura".format([i+1])
		atom_aura.visible=true;
		atom_aura.transform.origin=pos
		atom_aura.mesh=get_atom_aura_mesh()
		atom_aura.material_override=get_aura_material()
		aura_node.add_child(atom_aura)
		
	#create bonds (tubes)
	for bond in bonds:
		var index1=bond[0]-1 #adjust for indices being 1-based
		var index2=bond[1]-1
		var pos1=atoms[index1]["position"]
		var pos2=atoms[index2]["position"]
		
		#tube mesh
		var tube_mesh=MeshInstance3D.new()
		tube_mesh.name="tube_mesh{1}_{2}".format({"1":index1+1,"2":index2+1})
		tube_mesh.mesh=get_tube_mesh((pos1-pos2).length())
		tube_mesh.transform=get_tube_transform(pos1,pos2)
		molbody.add_child(tube_mesh)
		
		#tube collision
		var tube_col=CollisionShape3D.new()
		tube_col.name="tube_collision{1}_{2}".format({"1":index1+1,"2":index2+1})
		var cyl_shape=CylinderShape3D.new()
		cyl_shape.radius=get_tube_radius()
		cyl_shape.height=(pos1-pos2).length()#*1.1
		tube_col.shape=cyl_shape
		tube_col.transform=get_tube_transform(pos1,pos2)
		molbody.add_child(tube_col)
		
		#tube aura
		var tube_aura=MeshInstance3D.new()
		tube_aura.name="tube_aura{1}_{2}".format({"1":index1+1,"2":index2+1})
		tube_aura.visible=true
		tube_aura.mesh=get_tube_aura_mesh((pos1-pos2).length())
		tube_aura.material_override=get_aura_material()
		tube_aura.transform=get_tube_transform(pos1,pos2)
		aura_node.add_child(tube_aura)
		
	return mol
	
	
	
	mol_counter+=1
	return mol
