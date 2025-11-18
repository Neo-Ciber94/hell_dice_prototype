class_name DiceActive
extends Button

signal on_selected(this: DiceActive)

@onready var dice_ui: DiceUI = $DiceUI

@export var dice: Dice;

func _ready() -> void:
	if dice:
		dice_ui.dice = dice;
		dice_ui._prepare()

	pressed.connect(_on_pressed)
	
func _on_pressed() -> void:
	on_selected.emit(self)
