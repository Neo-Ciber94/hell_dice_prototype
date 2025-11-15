class_name DiceSelectionCard
extends Button

signal on_dice_changed()

@onready var dice_name_label: RichTextLabel = %DiceNameLabel
@onready var dice_ui: DiceUI = %DiceUI
@onready var dice_description_label: Label = %DiceDescriptionLabel

@export var dice: Dice:
	set(value):
		dice = value;
		_prepare()

func _ready() -> void:
	on_dice_changed.connect(_on_dice_changed)
	_prepare()
	
func _prepare() -> void:
	if dice_name_label == null:
		return;
		
	if dice:
		dice_name_label.text = dice.dice_name;
		dice_description_label.text = dice.dice_description;
		dice_ui.dice = dice;
		dice_ui.parent_card = self;
		dice_ui._prepare()

func _on_dice_changed() -> void:
	_prepare()
