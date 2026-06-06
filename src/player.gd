class_name Player
extends CharacterBody2D

@export var multiplayer_position: Vector2 = Vector2.ZERO 
@export var multiplayer_input: Vector2 = Vector2.ZERO 

var multiplayer_id = 0
var is_authority = false

var acceleration = 50.0
var max_speed = 500.0


func _enter_tree() -> void:
	is_authority = (multiplayer_id == multiplayer.get_unique_id())
	set_multiplayer_authority(multiplayer_id)

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	handle_input()
	move_and_slide()
	
	if is_authority:
		multiplayer_position = global_position
	else:
		global_position = lerp(global_position, multiplayer_position, 10.0 * delta)


func handle_input():
	if not is_authority:
		return
	
	var vec = Input.get_vector("game_left","game_right","game_up","game_down")
	if vec:
		velocity = velocity.move_toward(vec * max_speed, acceleration)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, acceleration)


func set_multiplayer(id: int):
	multiplayer_id = id


func _on_multiplayer_synchronizer_synchronized() -> void:
	pass
