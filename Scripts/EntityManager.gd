class_name EntityManager
extends Node

@export var doc_mgr_script :Resource=preload("res://Scripts/DocumentManager.gd")

var molecules = [] #stored in < z-matrix > format (for now)
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
	var outputs=await doc_mgr.read_zmat_from_files()
	var res=doc_mgr.convert_zmatrix_to_coordinates(outputs)
	#res is dictionry, res.coordinates: dict --> "symbol":"position" and res.bonds: arrays of size 2 
	molecules.append(outputs)
	var new_molecule=createMolecule(res)
	
