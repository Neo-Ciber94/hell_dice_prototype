class_name MessageManager
extends Control

const CHARACTER_DURATION = 0.1;

static var instance: MessageManager;

@onready var message_label: RichTextLabel = $MessageLabel

var _message_queue: Array[String]
var _is_writting: bool = false;

func _ready() -> void:
	instance = self;
	hide()
	
func show_message(text: String) -> void:
	_message_queue.push_back(text)
	await _write_next()

func _write_next() -> void:
	if _is_writting:
		return;
		
	_is_writting = true;
	show()
	
	while _message_queue.size() > 0:
		var next_message = _message_queue.pop_front();
		await _write_message(next_message)
		await get_tree().create_timer(1).timeout
		await _erase_message(next_message)
			
	hide()
	_is_writting = false;

func _write_message(msg: String) -> void:
	message_label.visible_characters = 0;
	message_label.text = msg;
	
	for idx in range(msg.length() + 1):
		message_label.visible_characters = idx;
		await get_tree().create_timer(CHARACTER_DURATION).timeout
	
func _erase_message(msg: String) -> void:
	for idx in range(msg.length(), -1, -1):
		message_label.visible_characters = idx;
		await get_tree().create_timer(CHARACTER_DURATION / 2).timeout
