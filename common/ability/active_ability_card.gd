class_name ActiveAbilityCard
extends PanelContainer

@onready var ability_name_label: RichTextLabel = %AbilityNameLabel
@onready var ablity_description_label: RichTextLabel = %AblityDescriptionLabel

@export var ability: AbilityData;

func _ready() -> void:
	if ability == null:
		return;
		
	EventBus.on_ability_activated.connect(_on_ability_activated);
		
	ability_name_label.text = ability.ability_name;
	ablity_description_label.text = ability.ability_description;

func _on_ability_activated(source: AbilityData) -> void:
	if ability == source:
		shake()

func shake() -> void:
	var tween = create_tween()
	tween.tween_property(self, "rotation_degrees", 3.0, 0.1)
	tween.tween_property(self, "rotation_degrees", -3.0, 0.1)
	tween.tween_property(self, "rotation_degrees", 3.0, 0.1)
	tween.tween_property(self, "rotation_degrees", -3.0, 0.1)
	tween.tween_property(self, "rotation_degrees", 0.0, 0.07)
