class_name AbilitySelectionCard
extends Button

signal on_selected(ability: AbilityData)

@onready var ability_name_label: RichTextLabel = %AbilityNameLabel
@onready var ability_description_label: RichTextLabel = %AbilityDescriptionLabel

@export var ability: AbilityData;

func _ready() -> void:
	ability_name_label.text = ability.ability_name;
	ability_description_label.text = ability.ability_description;
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	on_selected.emit(ability)
