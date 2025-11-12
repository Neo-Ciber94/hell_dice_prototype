class_name DiceSelectionCard
extends Button

@onready var dice_name_label: RichTextLabel = $MarginContainer/VBoxContainer/DiceNameLabel
@onready var dice: Dice = $MarginContainer/VBoxContainer/Dice
@onready var dice_description_label: Label = $MarginContainer/VBoxContainer/DiceDescriptionLabel

@export var behaviour: DiceBehaviour;

func _ready() -> void:
	if behaviour:
		dice_name_label.text = behaviour.dice_name;
		dice_description_label.text = behaviour.dice_description;
		dice.behaviour = behaviour;
		dice._prepare()
