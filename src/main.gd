extends Node2D

const PORT = 12345

@onready var host_button: Button = $Control/HostButton
@onready var ip_input: TextEdit = $Control/IPInput
@onready var connect_button: Button = $Control/ConnectButton
@onready var chat: Chat = $Chat
@onready var connected_player_label: Label = $Control/ConnectedPlayerLabel
var player_scene = preload("res://src/player.tscn")

func _ready() -> void:
	multiplayer.peer_connected.connect(_player_connected)
	multiplayer.peer_disconnected.connect(_player_disconnected)
	multiplayer.connected_to_server.connect(_connected_ok)
	multiplayer.connection_failed.connect(_connected_fail)
	multiplayer.server_disconnected.connect(_server_disconnected)
	
	$MultiplayerSpawner.add_spawnable_scene("res://src/player.tscn")
	$MultiplayerSpawner.set_spawn_function(add_player)
	


func _on_connect_button_pressed() -> void:
	print("Connecting to %s:%s" % [ip_input.text, str(PORT)])
	_create_client(ip_input.text, PORT)


func _on_host_button_pressed() -> void:
	print("Hosting")
	_create_server(PORT)


func _create_client(server_ip: String, server_port: int):
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_client(server_ip, server_port)
	multiplayer.multiplayer_peer = peer
	if err:
		print("Error client: ", err)
		chat.add_message("Failed creating server err: %s" % [err])
	else:
		print("Id: ", multiplayer.get_unique_id())
		chat.add_message("Created client to server %s:%s" % [server_ip, server_port])
	


func _create_server(port: int):
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_server(port)
	multiplayer.multiplayer_peer = peer
	if err:
		print("Error server: ", err)
		chat.add_message("Failed connecting err: %s" % [err])
	else:
		print("Id: ", multiplayer.get_unique_id())
		chat.add_message("Created server at port %s" % [port])


func add_player(id: int):
	var player: Player = player_scene.instantiate()
	player.position = Vector2(randf_range(30,300), randf_range(30,300))
	player.set_multiplayer(id)
	return player


## Signaux
func _player_connected(id: int):
	print("_player_connected %s" % [id])
	chat.add_message("Player connected %s" % [id])
	
	if multiplayer.is_server():
		$MultiplayerSpawner.spawn(id)

func _player_disconnected(id: int):
	print("_player_disconnected %s" % [id])
	chat.add_message("Player disconnected %s" % [id])

func _connected_ok():
	print("_connected_ok")
	chat.add_message("Connected successfully")

func _connected_fail():
	print("_connected_fail")
	chat.add_message("Connected failed")

func _server_disconnected():
	print("_server_disconnected")
	chat.add_message("Server disconnected")
