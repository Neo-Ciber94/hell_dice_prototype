class_name DicePreview
extends TextureRect

@onready var dice_preview: TextureRect = $"."
@onready var label: Label = $Label

@export var dice: Dice;

func _ready() -> void:
	dice_preview.texture = dice.dice_texture;
	label.text = str(dice.get_dice_sides().front().side_value)
	
