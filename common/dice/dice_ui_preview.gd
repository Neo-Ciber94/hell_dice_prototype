class_name DicePreview
extends TextureRect

@onready var dice_preview: TextureRect = $"."
@onready var label: Label = $Label

@export var dice: Dice;
@export var show_current_dice_value: bool = false;

func _ready() -> void:
	refresh_dice()

func refresh_dice() -> void:
	if dice == null:
		return;
		
	dice_preview.texture = dice.dice_texture;
	
	if show_current_dice_value and dice.get_selected_dice_side():
		label.text = dice.get_selected_dice_side().side_text
	else:
		label.text = dice.get_dice_sides().front().side_text
		
	label.add_theme_color_override("font_color", dice.dice_text_color)
	label.add_theme_color_override("font_color", dice.dice_text_color)
	label.add_theme_constant_override("outline_size", dice.dice_outline_size)
	label.add_theme_color_override("font_outline_color", dice.dice_outline_color)
