class_name WinScreen
extends ColorRect

signal on_next_run()

@onready var your_score_label: RichTextLabel = %YourScoreLabel
@onready var continue_button: Button = %ContinueButton

func _ready() -> void:
	continue_button.pressed.connect(_on_next_run)
	
func show_total_score(current_score: int, target_score: int) -> void:
	show()
	
	your_score_label.text = "[wave]Your Score: {score} / {target}[/wave]".format({
		score = current_score,
		target = target_score
	})
	
func _on_next_run() -> void:
	on_next_run.emit()
	hide()
