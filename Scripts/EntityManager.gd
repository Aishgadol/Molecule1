class_name EntityManager
extends Node


#  |    |  |  |    |
#  \/  \/ \/  \/   \/
var zmat_molecules = [] #zmat: string
var xyz_molecules=[] #xyz: dict: {"xyz":str , "bonds":[ [atom_i,atom_j] , [atom_k,atom_m] ...]}
# ^^^^ these two might not be necesary cuz if mol changes, they need to change too,
# too much work updating for every little change :(

var displayed_molecules=[] #displayable items for world display

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	

	print("good morning from entity maanger")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	

func sendZmat(zmat:String)->void:
	print("\ngot zmat: \n",zmat)
	
#mol: { "zmat":zmat_string (string) , "xyz": xyz_string (string), "bonds":bonds (array) }
func newMol(mol):
	for x in mol:
		print(x," :\n",mol[x])
