extends Node2D

const DEFAULT_ADDRESS = "172.20.10.2"
const PORT = 12345

@onready var host_button: Button = $Control/HostButton
@onready var ip_input: TextEdit = $Control/IPInput
@onready var connect_button: Button = $Control/ConnectButton
@onready var chat: Chat = $Chat
@onready var connected_player_label: Label = $Control/ConnectedPlayerLabel

var players = {}

func _ready() -> void:
	multiplayer.peer_connected.connect(_player_connected)
	multiplayer.peer_disconnected.connect(_player_disconnected)
	multiplayer.connected_to_server.connect(_connected_ok)
	multiplayer.connection_failed.connect(_connected_fail)
	multiplayer.server_disconnected.connect(_server_disconnected)

func _process(delta: float) -> void:
	connected_player_label.text = "Connected: "
	var players_sorted = players.keys()
	players_sorted.sort()
	for player in players_sorted:
		connected_player_label.text += str(player) + ", "

## Buttons

func _on_connect_button_pressed() -> void:
	var ip = DEFAULT_ADDRESS
	if not ip_input.text.is_empty():
		ip = ip_input.text
	print("Connecting to %s:%s" % [ip, str(PORT)])
	_create_client(ip, PORT)


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
	chat.add_message("Connected to %s:%s" % [server_ip, server_port])


func _create_server(port: int):
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_server(port)
	multiplayer.multiplayer_peer = peer
	if err:
		print("Error server: ", err)
	print("Id: ", multiplayer.get_unique_id())
	chat.add_message("Server created at port %s" % [port])
	


## Signaux

func _player_connected(id: int):
	print("_player_connected %s" % [id])
	chat.add_message("Player connected: id = %s" % [id])
	players[id] = true

func _player_disconnected(id: int):
	print("_player_disconnected %s" % [id])
	chat.add_message("Player disconnected: id = %s" % [id])
	players[id] = false

func _connected_ok():
	chat.add_message("Successfully connected to server")
	print("_connected_ok")

func _connected_fail():
	chat.add_message("Failed connection to server")
	print("_connected_fail")

func _server_disconnected():
	chat.add_message("Server disconnected")
	print("_server_disconnected")
