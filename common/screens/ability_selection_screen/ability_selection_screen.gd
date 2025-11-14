class_name AbilitySelectionScreen
extends Control

const ABILITY_SELECTION_CARD = preload("uid://b3f0ybtchurne")

signal on_ability_selected(ability: AbilityData)

@onready var ability_container: HBoxContainer = %AbilityContainer
@onready var select_button: Button = %SelectButton
@onready var skip_button: Button = %SkipButton

var _selected_ability: AbilityData;

func _ready() -> void:
	select_button.pressed.connect(_on_select)
	skip_button.pressed.connect(_on_skip)
	select_button.disabled = true;
	hide()
	
func open_ability_selection(_board: Board) -> void:
	await _fade_in();
	
	for child in ability_container.get_children():
		child.queue_free()
		
	for ability in _get_available_abilities():
		var ability_card = ABILITY_SELECTION_CARD.instantiate() as AbilitySelectionCard
		ability_card.ability = ability;
		ability_container.add_child(ability_card)
		
func _fade_in() -> void:
	var tween = create_tween();
	self.modulate.a = 0.0;
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "modulate:a", 1.0, 0.5).from(0);
	tween.tween_property(self, "scale", Vector2.ONE, 0.5).from(Vector2.ONE * 0.8)
	await tween.finished
		
func _get_available_abilities() -> Array[AbilityData]:
	return []
	
func _on_select() -> void:
	if _selected_ability == null:
		return;
		
	on_ability_selected.emit(_selected_ability)
	_selected_ability = null;
	hide()
	
func _on_skip() -> void:
	hide()
