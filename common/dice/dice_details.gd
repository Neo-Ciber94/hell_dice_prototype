class_name DiceDetails
extends PanelContainer

@onready var dice_preview: DicePreview = $MarginContainer/VBoxContainer/DiceContainer/DicePreview
@onready var dice_name_label: RichTextLabel = $MarginContainer/VBoxContainer/DiceNameLabel
@onready var dice_description_label: RichTextLabel = $MarginContainer/VBoxContainer/DiceDescriptionLabel

func _ready() -> void:
	EventBus.on_show_dice_details.connect(_on_show_dice_details)
	EventBus.on_hide_dice_details.connect(_on_hide_dice_details)
	hide()
	
func _on_show_dice_details(dice: Dice) -> void:
	dice_name_label.text = dice.dice_name;
	dice_description_label.text = dice.dice_description;
	dice_preview.dice = dice;
	dice_preview.show_current_dice_value = true;
	dice_preview.refresh_dice()
	show()
	
func _on_hide_dice_details() -> void:
	hide()
