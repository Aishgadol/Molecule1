class_name Molecule
extends Node3D

staic var id_counter:int=0
var id : int
var changed : bool=true
var atoms : Array = []
var bonds_list :Dictionary={}
var atom_dict : Dictionary ={}
var atoms_local_transform : Dictionary={} #might not need this

func getId()-> int:
	return self.id
	
func setId(_id:int)->void:
	self.id=_id
	
func getAtoms()->Array:
	return self.atoms
	
func setAtoms(_atoms:Array)->void:
	self.atoms=_atoms
	
func addAtom(_atom :Atom)->void:
	changed=true
	self.atoms.append(_atom)
	bonds_list[_atom.getId()]=[]
	
	
	var connections =bonds_list[atom_id]
	for bond in connections:
		print(" Atom ID: ",bond["id"], ", Bond Order: ",bond["order"])
	
	
	
	
	
func add_bond(atom1_id:int,atom2_id:int, bond_order:int):
	bonds_list[atom1_id].append({"id": atom2_id, "order": bond_order})
	bonds_list[atom2_id].append({"id": atom1_id, "order": bond_order})
	
	
	
func _init():
	id=id_counter
	id_counter+=1
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(changed):
		#this part is described in project notes
		print("haha")
		changed=false
	else:
		print("okay")
		
