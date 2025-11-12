class_name DiceSelectionCard
extends Button

signal on_dice_changed()

@onready var dice_name_label: RichTextLabel = $MarginContainer/VBoxContainer/DiceNameLabel
@onready var dice: Dice = %Dice
@onready var dice_description_label: Label = $MarginContainer/VBoxContainer/DiceDescriptionLabel
@onready var outline: Panel = $Outline

@export var behaviour: DiceBehaviour:
	set(value):
		behaviour = value;
		_prepare()

func _ready() -> void:
	on_dice_changed.connect(_on_dice_changed)
	_prepare()
	
func _prepare() -> void:
	if dice_name_label == null:
		return;
		
	if behaviour:
		dice_name_label.text = behaviour.dice_name;
		dice_description_label.text = behaviour.dice_description;
		dice.behaviour = behaviour;
		dice.parent_card = self;
		dice._prepare()

func _process(_delta: float) -> void:
	outline.visible = is_hovered() or is_pressed() or has_focus()

func _on_dice_changed() -> void:
	_prepare()
