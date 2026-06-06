extends Node2D

const PORT = 12345

@onready var host_button: Button = $Control/HostButton
@onready var ip_input: TextEdit = $Control/IPInput
@onready var connect_button: Button = $Control/ConnectButton


func _ready() -> void:
	multiplayer.peer_connected.connect(_player_connected)
	multiplayer.peer_disconnected.connect(_player_disconnected)
	multiplayer.connected_to_server.connect(_connected_ok)
	multiplayer.connection_failed.connect(_connected_fail)
	multiplayer.server_disconnected.connect(_server_disconnected)


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
	print("Id: ", multiplayer.get_unique_id())
	


func _create_server(port: int):
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_server(port)
	multiplayer.multiplayer_peer = peer
	if err:
		print("Error server: ", err)
	print("Id: ", multiplayer.get_unique_id())


## Signaux
func _player_connected(id: int):
	print("_player_connected %s" % [id])
	if is_multiplayer_authority():
		$Game/MultiplayerSpawner.add_spawnable_scene("res://src/player.tscn")

func _player_disconnected(id: int):
	print("_player_disconnected %s" % [id])

func _connected_ok():
	print("_connected_ok")

func _connected_fail():
	print("_connected_fail")

func _server_disconnected():
	print("_server_disconnected")
