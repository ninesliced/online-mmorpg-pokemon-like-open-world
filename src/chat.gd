class_name Chat
extends Node

@onready var chat_log: Label = $"../Control/ChatLog"
@onready var chat_input: TextEdit = $"../Control/ChatInput"

func _send_chat_message(msg: String):
	add_message.rpc(msg)
	_clear_chat_input()

func _clear_chat_input():
	chat_input.text = ""

func _on_send_message_pressed() -> void:
	_send_chat_message(chat_input.text)

@rpc("any_peer", "call_local")
func add_message(message: String):
	var remote_id = multiplayer.get_remote_sender_id()
	chat_log.text += "%s : %s\n" % [remote_id, message]


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("send_chat"):
		_send_chat_message(chat_input.text)
