extends Node3D

@onready var pause_menu=$PauseMenu
@onready var player=$World/Player
@onready var camera = $World/Player/PlayerCamera
@onready var anim_player=$World/WorldAnimation

@onready var going_back=false
var paused: bool = false
func _ready() ->void:
	#camera.global_transform.origin=Vector3(0,9,0)
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
