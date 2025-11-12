class_name GameOverScreen
extends ColorRect

@onready var restart_button: Button = %RestartButton

func _ready() -> void:
	restart_button.pressed.connect(_on_restart_game)
	
func _on_restart_game() -> void:
	get_tree().reload_current_scene()
