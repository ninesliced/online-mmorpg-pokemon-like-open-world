class_name Player
extends CharacterBody2D

var multiplayer_id = 0
var is_authority = false

var acceleration = 50.0
var max_speed = 500.0

func _ready() -> void:
	is_authority = (multiplayer_id == multiplayer.get_unique_id())
	set_multiplayer_authority(multiplayer_id)

func _physics_process(delta: float) -> void:
	if not is_authority:
		return
	
	var vec = Input.get_vector("game_left","game_right","game_up","game_down")
	if vec:
		velocity = velocity.move_toward(vec * max_speed, acceleration)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, acceleration)
	
	move_and_slide()

func set_multiplayer(id: int):
	multiplayer_id = id
