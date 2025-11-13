class_name DicePreview
extends TextureRect

@onready var dice_preview: TextureRect = $"."
@onready var label: Label = $Label

@export var behaviour: DiceBehaviour;

func _ready() -> void:
	dice_preview.texture = behaviour.dice_texture;
	label.text = str(behaviour.get_dice_sides().front().side_value)
	
