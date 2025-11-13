@tool
class_name DiceUI
extends Button

signal on_finished()

@onready var container: TextureRect = $Container
@onready var value_label: Label = $Container/ValueLabel

@export var dice: Dice:
	set(value):
		dice = value;
		
@export var duration: float = 1.0;

@export_group("Animations")
@export_tool_button("Bring to Front", "Callable") var _bring_to_front = bring_to_front;

var parent_card: DiceSelectionCard;

var _had_rolled = false;
var _side_index: int = 0;

func _ready() -> void:
	pressed.connect(_on_dice_pressed)
	
	if dice:
		dice = dice.duplicate(true)
	
	_prepare()

func _get_drag_data(_at_position: Vector2) -> Variant:
	if parent_card && parent_card.disabled:
		return null;
	
	const DICE_PREVIEW = preload("uid://dpgm01o6sb5x3")

	if dice and dice.dice_texture:
		var preview := Control.new()
		var dice_preview := DICE_PREVIEW.instantiate() as DicePreview;
		dice_preview.dice = dice;
		dice_preview.position = -dice_preview.custom_minimum_size / 2.0
		preview.add_child(dice_preview)
		set_drag_preview(preview)

	return self

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	var other_dice = data as DiceUI;
	
	if other_dice == null || other_dice == self:
		return false;
		
	if other_dice.parent_card and parent_card:
		return false;
		
	if (parent_card and parent_card.disabled) || (other_dice.parent_card and other_dice.parent_card.disabled):
		return false;
		
	return true;

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var other = data as DiceUI;
	
	if other == null:
		return;
		
	var other_dice: Dice = other.dice as Dice;
	var temp: Dice = dice as Dice;
	dice = other_dice
	other.dice = temp 
	self._prepare()
	other._prepare()
	
	if parent_card:
		parent_card.dice = other_dice;
		parent_card.on_dice_changed.emit()
		
	if other.parent_card:
		other.parent_card.dice = other.dice;
		other.parent_card.on_dice_changed.emit()
		
	if other.parent_card:
		EventBus.on_dice_selected.emit(self)

func _prepare() -> void:
	if dice == null || container == null:
		return;
		
	var sides = dice.get_dice_sides();
	_set_side(sides.front())
		
	container.texture = dice.dice_texture;
	value_label.add_theme_color_override("font_color", dice.dice_text_color)
		
func _set_side(side: DiceSide, animate: bool = false) -> void:
	if animate:
		await _animate_roll(_side_index, false, 0.1)
		await _animate_roll(_side_index + 1, false, 0.1)
		await _animate_roll(_side_index + 1, true, 0.1)
		
	value_label.text = side.side_text;

func _on_dice_pressed() -> void:
	if _had_rolled || dice == null:
		return;
		
	var sides = dice.get_dice_sides();
	_side_index = (_side_index + 1) % sides.size()
	var side = sides.get(_side_index)
	_set_side(side, true)

func roll_dice(rng: RNG) -> void:
	_had_rolled = true;
	dice.roll_dice(rng)
	
	var sides = dice.get_dice_sides_with_selected_as_last()
	var anim_duration = duration / sides.size()
	
	for idx in sides.size():
		var side = sides.get(idx)
		var is_last = idx == sides.size() - 1;
		await _animate_roll(idx, is_last, anim_duration)
		_set_side(side)
		
	on_finished.emit()

func get_dice_value() -> int:
	return dice.get_dice_value()

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
