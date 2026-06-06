extends Node2D

const IP_ADDRESS = ""

@onready var host_button: Button = $Control/HostButton
@onready var ip_input: TextEdit = $Control/IPInput
@onready var port_input: TextEdit = $Control/PortInput
@onready var connect_button: Button = $Control/ConnectButton


func _ready() -> void:
	multiplayer.peer_connected.connect(_player_connected)
	multiplayer.peer_disconnected.connect(_player_disconnected)
	multiplayer.connected_to_server.connect(_connected_ok)
	multiplayer.connection_failed.connect(_connected_fail)
	multiplayer.server_disconnected.connect(_server_disconnected)


func _on_connect_button_pressed() -> void:
	print("Connecting to %s:%s" % [ip_input.text, port_input.text])
	_create_client(ip_input.text, int(port_input.text))


func _on_host_button_pressed() -> void:
	pass # Replace with function body.


func _create_client(server_ip: String, server_port: int):
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(server_ip, server_port)
	multiplayer.multiplayer_peer = peer


func _create_server(port: int):
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(port)
	multiplayer.multiplayer_peer = peer


## Signaux

func _player_connected(id: int):
	print("_player_connected %s" % [id])

func _player_disconnected(id: int):
	print("_player_disconnected %s" % [id])

func _connected_ok():
	print("_connected_ok")

func _connected_fail():
	print("_connected_fail")

func _server_disconnected():
	print("_server_disconnected")
