extends Node2D

@onready var host_button: Button = $Control/HostButton
@onready var ip_input: TextEdit = $Control/IPInput
@onready var connect_button: Button = $Control/ConnectButton


func _on_connect_button_pressed() -> void:
	print(ip_input.text)


func _on_host_button_pressed() -> void:
	pass # Replace with function body.
