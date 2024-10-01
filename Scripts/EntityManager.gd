class_name EntityManager
extends Node

@export var doc_mgr_script :Resource=preload("res://Scripts/DocumentManager.gd")

#  |    |  |  |    |
#  \/  \/ \/  \/   \/
var zmat_molecules = [] #zmat: string
var xyz_molecules=[] #xyz: dict: {"xyz":str , "bonds":[ [atom_i,atom_j] , [atom_k,atom_m] ...]}
# ^^^^ these two might not be necesary cuz if mol changes, they need to change too,
# too much work updating for every little change :(

var displayed_molecules=[] #displayable items for world display
var doc_mgr

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	doc_mgr=doc_mgr_script.new()
	add_child(doc_mgr)
	doc_mgr.run()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("importZmat"):
		_on_import_zmat_pressed()

func _on_import_zmat_pressed()->void:
	var res = await doc_mgr.import_zmat()
	print (res.zmat)
	print (res.bonds)
	print (res.filename)
	#res is dictionry, {res.zmat, res.xyz,res.bonds, res.filename} where:
	#res.zmat is str, res.xyz is str, res.bonds
	# {"xyz":str , "bonds":[ [atom_i,atom_j] , [atom_k,atom_m] ...]}
	
	#zmat_molecules.append(res.zmat)
	#xyz_molecules.append(res.xyz)
	
	#displayed_molecules.append(build_mol(res.xyz))
	
func _on_import_xyz_pressed()->void:
	var outputs=await doc_mgr.read_xyz_from_files #(outputs is simply in xyz format)
	var res=doc_mgr.convert_xyz_to_zmat(outputs)
	
