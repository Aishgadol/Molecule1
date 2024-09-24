class_name Atom
extends Node3D

static var id_counter:int =0

var id : int 
var numElectrons : int
var elementSymbol: String
var atomicNumber : int


func _init(atomic_num:int):
	atomicNumber=atomic_num
	id=id_counter
	id_counter+=1
	numElectrons=atomicNumber
	
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
