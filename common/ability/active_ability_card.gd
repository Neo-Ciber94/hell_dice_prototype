class_name ActiveAbilityCard
extends PanelContainer

@onready var ability_name_label: RichTextLabel = %AbilityNameLabel
@onready var ablity_description_label: RichTextLabel = %AblityDescriptionLabel

@export var ability: AbilityData;

func _ready() -> void:
	if ability == null:
		return;
		
	ability_name_label.text = ability.ability_name;
	ablity_description_label.text = ability.ability_description;
