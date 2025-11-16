@tool
class_name DiceUI
extends RigidBody2D

signal on_finished()

@onready var button: Button = $Button
@onready var container: TextureRect = $Button/Container
@onready var value_label: Label = $Button/Container/ValueLabel
@onready var hover_timer: Timer = $HoverTimer
@onready var roll_timer: Timer = $RollTimer

@export var dice: Dice:
	set(value):
		dice = value;
		
@export var duration: float = 1.0;

@export_group("Animations")
@export_tool_button("Bring to Front", "Callable") var _bring_to_front = bring_to_front;

var parent_card: DiceSelectionCard;

var _had_rolled = false;
var _side_index: int = 0;
var is_previewed: bool = false;

func _ready() -> void:
	button.pressed.connect(_on_dice_pressed)
	
	if dice:
		dice = dice.duplicate(true)
	
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	hover_timer.timeout.connect(_on_preview_dice)
	_prepare()

func _on_mouse_entered() -> void:
	hover_timer.start(1.0)
	
func _on_mouse_exited() -> void:
	hover_timer.stop()
	
	if is_previewed:
		EventBus.on_hide_dice_details.emit()

func _on_preview_dice() -> void:
	is_previewed = true;
	EventBus.on_show_dice_details.emit(dice)

func _on_dice_changed() -> void:
	var side = dice.get_selected_dice_side()
	_set_side(side, true)

func _prepare() -> void:
	if dice == null || container == null:
		return;
		
	if not dice.changed.is_connected(_on_dice_changed):
		dice.changed.connect(_on_dice_changed)
		
	var sides = dice.get_dice_sides();
	_set_side(sides.front())
		
	container.texture = dice.dice_texture;
	value_label.add_theme_color_override("font_color", dice.dice_text_color)
	value_label.add_theme_constant_override("outline_size", dice.dice_outline_size)
	value_label.add_theme_color_override("font_outline_color", dice.dice_outline_color)
		
func _set_side(side: DiceSide, animate: bool = false) -> void:
	if animate:
		await shake()
		
	value_label.text = side.side_text;

func _on_dice_pressed() -> void:
	if _had_rolled || dice == null:
		return;
		
	var sides = dice.get_dice_sides();
	_side_index = (_side_index + 1) % sides.size()
	var side = sides.get(_side_index)
	_set_side(side, true)

var _is_rolling: bool = false;

func roll_dice_to_dir(rng: RNG, dir: Vector2, force_amount: float = 1000, torque_amount: float = 1000) -> void:
	if _is_rolling:
		return;
		
	#_is_rolling = true;
	get_tree().create_timer(0.25).timeout.connect(func(): set_deferred("_is_rolling", true))
	
	roll_timer.stop()
	roll_timer.start(0.1)
	dice.roll_dice(rng)
	roll_timer.timeout.connect(_on_rolling_timeout)
	
	_set_random_side()
	apply_impulse(dir * force_amount)
	apply_torque(torque_amount)

func _on_rolling_timeout() -> void:
	_set_random_side()
	
var _cur_side: DiceSide;
	
func _set_random_side() -> void:
	var dices = dice.get_dice_sides()
	dices.erase(_cur_side)

	_cur_side = dices.pick_random()
	_set_side(_cur_side)
	
func _process(_delta: float) -> void:
	if _is_rolling and not is_moving():
		_is_rolling = false;
		var selected = dice.get_selected_dice_side()
		roll_timer.stop()
		_set_side(selected)
		on_finished.emit()
			
func is_moving() -> bool:
	return linear_velocity.length() > 1.0 or abs(angular_velocity) > 1.0

func roll_dice(rng: RNG) -> void:
	_had_rolled = true;
	dice.roll_dice(rng)
	
	var sides = dice.get_dice_sides_with_selected_as_last()
	var anim_duration = duration / sides.size()
	
	for idx in sides.size():
		var side = sides.get(idx)
		var is_last = idx == sides.size() - 1;
		var move_right = idx % 2 == 0;

		if not is_last:
			await _move(move_right, anim_duration)
		else:
			await reset_transform(anim_duration)
			
		_set_side(side)
		
	on_finished.emit()

func get_dice_value() -> int:
	return dice.get_dice_value()

func _move(move_right: bool, anim_duration: float) -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	var dir = 1 if move_right else -1;
	var wobble_offset = Vector2(dir * 2, 0)
	var wobble_rotation = deg_to_rad(5) if move_right else deg_to_rad(-5);

	tween.tween_property(container, "position", wobble_offset, anim_duration)
	tween.tween_property(container, "rotation", wobble_rotation, anim_duration)
	tween.tween_property(container, "scale", Vector2.ONE, anim_duration)
	tween.play()

	await tween.finished

func shake() -> void:
	var anim_duration = duration / dice.get_dice_sides().size()
	await _move(true, anim_duration)
	await _move(false, anim_duration)
	await reset_transform(anim_duration)

func bring_to_front() -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT_IN)
	tween.set_trans(Tween.TRANS_SINE)
	
	tween.tween_property(container, "scale", Vector2.ONE * 0.90, 0.4)
	tween.tween_property(container, "scale", Vector2.ONE * 1.2, 0.1)
	await tween.finished

func reset_transform(anim_duration: float = 0.25) -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_OUT_IN)
	tween.set_trans(Tween.TRANS_SINE)
	
	tween.tween_property(container, "scale", Vector2.ONE, anim_duration)
	tween.tween_property(container, "position", Vector2.ZERO, anim_duration)
	tween.tween_property(container, "rotation", 0, anim_duration)
	await tween.finished

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
		button.set_drag_preview(preview)

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
