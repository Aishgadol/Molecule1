extends Node3D

@onready var pause_menu=$PauseMenu
@onready var player=$World/Player
@onready var camera = $World/Player/PlayerCamera
@onready var level=$World/Level
@onready var going_back=false
@onready var explosion_scene:PackedScene =preload("res://Scenes/vfx_explosion.tscn")

var sphere_radius:float=4.0 #might change later if atoms become smaller/larger
var paused: bool = false
func _ready() ->void:
	camera.set_root(self)
	camera.rotation_degrees=Vector3(45,105,0)
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause") and !going_back:  # This is typically mapped to the ESC key
		paused = !paused
		if pause_menu.getCurrentMenu()=="option":
			return;
		pause_menu.visible = paused
		if paused:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
		camera.set_paused_state(paused)  # Notify the camera script of the pause state
		

func _on_back_to_main_button_pressed() -> void:
	going_back=true
	$World/Player/CanvasLayer.visible=false
	
#called by the player's camera script when the object is released
func check_for_merge(released_object):
	print("checking for merge")
	for other_grabbable in get_tree().get_nodes_in_group("mergeable"):
		if other_grabbable != released_object:
			var dist=released_object.global_transform.origin.distance_to(other_grabbable.global_transform.origin)
			if dist <= sphere_radius:
				var midpoint= (released_object.global_transform.origin + other_grabbable.global_transform.origin)/2
				print("MERGE DETECTED, youre holding: ",released_object.name," merging with: ",other_grabbable.name)
				#remove the objects from existence :)
				var new_object = released_object.duplicate()
				new_object.name=released_object.name+""
				released_object.queue_free()
				other_grabbable.queue_free()
				
				#add explosion vfx 
				var explosion_instance=explosion_scene.instantiate()
				level.add_child(explosion_instance)
				explosion_instance.global_transform.origin=midpoint
				var scale_factor=lerp(1.0,10.0,clamp((self.global_transform.origin.distance_to(released_object.global_transform.origin)-5.0)/(50.0-5.0),0.0,1.0))
				for child in explosion_instance.get_children():
					child.scale=Vector3(scale_factor,scale_factor,scale_factor)
					child.emitting=true
				
				#wait for explosion to finish
				await get_tree().create_timer(0.37).timeout
			
				#create ew atom (sphere for now, maybe molecule later) at the midpoint of intersections
				level.add_child(new_object)
				new_object.global_transform.origin=midpoint
				new_object.get_node("aura").visible=false

				#clean up explosion instance
				explosion_instance.queue_free()
				#explosion_instance.queue_free()
				break
