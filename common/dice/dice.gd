@tool
class_name Dice
extends Control

signal on_finished()

@onready var container: PanelContainer = $Container
@onready var value_label: Label = $Container/ValueLabel

@export var behaviur: DiceBehaviour;
@export var duration: float = 1.0;

@export_group("Animations")
@export_tool_button("Bring to Front", "Callable") var _bring_to_front = bring_to_front;

func _ready() -> void:
	behaviur = behaviur.duplicate(true)
	
	if not Engine.is_editor_hint():
		var sides = behaviur.get_dice_sides();
		var front = sides.front() as DiceSide;
		value_label.text = front.side_text;

func roll_dice(rng: RNG) -> void:
	behaviur.roll_dice(rng)
	
	var sides = behaviur.get_dice_sides_with_selected_as_last()
	var anim_duration = duration / sides.size()
	
	for idx in sides.size():
		var side = sides.get(idx)
		var is_last = idx == sides.size() - 1;
		await _animate_roll(idx, is_last, anim_duration)
		value_label.text = side.side_text

	on_finished.emit()

func get_dice_value() -> int:
	return behaviur.get_dice_value()

func _animate_roll(dice_index: int, is_last: bool, anim_duration: float) -> void:
		
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

	var wobble_offset = Vector2.ZERO;
	var wobble_rotation = 0.0;
	
	container.scale = Vector2.ONE
	
	if not is_last:
		var dir = 1 if dice_index % 2 == 0 else -1;
		wobble_offset = Vector2(dir * 2, 0)
		wobble_rotation = deg_to_rad(5) if dice_index % 2 == 0 else deg_to_rad(-5);

	tween.tween_property(container, "position", wobble_offset, anim_duration)
	tween.tween_property(container, "rotation", wobble_rotation, anim_duration)
	tween.tween_property(container, "scale", Vector2.ONE, anim_duration)
	tween.play()

	await tween.finished

func bring_to_front() -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT_IN)
	tween.set_trans(Tween.TRANS_SINE)
	
	tween.tween_property(container, "scale", Vector2.ONE * 0.90, 0.4)
	tween.tween_property(container, "scale", Vector2.ONE * 1.2, 0.1)
	await tween.finished
