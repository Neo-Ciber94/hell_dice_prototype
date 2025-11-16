class_name DiceRollBoard
extends Control

const DICE_UI = preload("uid://ynjdjcukvk4c")

signal on_score_changed(new_value: int)
signal on_accumulated_score_changed(new_value: int)
signal on_round_changed(new_value: int)
signal on_rolls_left_changed(new_value: int)

@onready var roll_dice_button: Button = %RollDiceButton
@onready var center_marker: Marker2D = $CenterMarker
@onready var dice_spawn_points: Control = $DiceSpawnPoints
@onready var board: PanelContainer = %Board
@onready var dice_alignment_container: HBoxContainer = %DiceAlignmentContainer
@onready var accumulated_score_label: Label = %AccumulatedScoreLabel
@onready var score_label: RichTextLabel = %ScoreLabel
@onready var current_round_label: RichTextLabel = %CurrentRoundLabel
@onready var rolls_left_label: RichTextLabel = %RollsLeftLabel

@export var dices: Array[Dice] = []
@export var abilities: Array[AbilityData] = []
@export var target_score: int = 100;
@export var dice_roll_left: int = 7;

var _current_round: int = 1;
var _current_score: int = 0;

var _board_dices: Array[DiceUI] = []
var _dice_rolling_count: int = 0;
var _is_rolling: bool = false;

var _score_tween: Tween;

func _ready() -> void:
	roll_dice_button.pressed.connect(roll_dices)
	on_score_changed.connect(_on_score_changed)
	on_accumulated_score_changed.connect(_on_accumulated_score_changed)
	on_round_changed.connect(_on_round_changed)
	on_rolls_left_changed.connect(_on_rolls_left_changed)
	
	accumulated_score_label.hide()
	
	_on_score_changed(_current_score, false)
	_on_round_changed(_current_round)
	_on_rolls_left_changed(dice_roll_left)

func _on_round_changed(new_value: int) -> void:
	_current_round = new_value;
	current_round_label.text = str(new_value)
	
func _on_rolls_left_changed(new_value: int) -> void:
	_current_score = new_value;
	rolls_left_label.text = str(new_value)

func _on_score_changed(new_value: int, animate: bool = true) -> void:
	if animate:
		if _score_tween:
			_score_tween.stop()
			
		_score_tween = create_tween()
		
		var score_callback = func(val: int):
			score_label.text = "${current} / ${target}".format({
				current = val,
				target = target_score
			})
			
		_score_tween.tween_method(score_callback, _current_score, new_value, 0.5);
	else:
		score_label.text = "${current} / ${target}".format({
			current = new_value,
			target = target_score
		})

func _on_accumulated_score_changed(new_value: int) -> void:
	accumulated_score_label.text = "+%s" % new_value;
	
func roll_dices() -> void:
	if _is_rolling:
		return;
		
	_is_rolling = true;
	for d in _board_dices:
		d.queue_free()
		
	_board_dices.clear()
	
	var spawn_point = dice_spawn_points.get_children().pick_random() as Marker2D;
	var dir = spawn_point.global_position.direction_to(center_marker.global_position)
	_dice_rolling_count = dices.size()
	
	var rng = RNG.new();
	
	for dice in dices:
		var board_dice = DICE_UI.instantiate() as DiceUI;
		board_dice.dice = dice;
		board.add_child(board_dice)
		_board_dices.push_back(board_dice)
		board_dice.global_position = spawn_point.global_position + Vector2(
			randf_range(-1, 1),
			randf_range(-1, 1)
		)
		
		board_dice.roll_dice_to_dir(rng, dir)
		board_dice.on_finished.connect(_on_dice_finished_rolling)

func _on_dice_finished_rolling() -> void:
	_dice_rolling_count -= 1;
	
	if _dice_rolling_count == 0:
		await _align_dices()
		await _on_roll_finished()
		_is_rolling = false;

func _on_roll_finished() -> void:
	var score: int = 0;
	var b = Board.new() # delete
	
	for board_dice: DiceUI in _board_dices:
		score = board_dice.dice.calculate_dice_score(b, score)
		accumulated_score_label.show()
		on_accumulated_score_changed.emit(score)
		await board_dice.bring_to_front()

	on_score_changed.emit(_current_score + score)
	await get_tree().create_timer(2.0).timeout
	accumulated_score_label.hide()

func _align_dices() -> void:
	_prepare_align_markers()
		
	const DURATION = 0.5;
	
	var markers = dice_alignment_container.get_children() as Array[ColorRect]
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)

	for idx in _board_dices.size():
		var board_dice = _board_dices.get(idx) as DiceUI;
		var marker = markers.get(idx)
		board_dice.freeze = true;
		
		var center =  marker.global_position + marker.size * 0.5;
		tween.tween_property(board_dice, "global_position", center, DURATION)
		tween.parallel().tween_property(board_dice, "global_rotation", 0, DURATION)
		
	await tween.finished;

func _prepare_align_markers() -> void:
	var markers = dice_alignment_container.get_children()
	var first = markers.get(0) as ColorRect;
	
	for idx in range(1, markers.size()):
		var marker = markers.get(idx) as ColorRect;
		marker.queue_free()
		
	await get_tree().process_frame
		
	for idx in range(1, _board_dices.size()):
		var marker = first.duplicate() as ColorRect;
		dice_alignment_container.add_child(marker)
		dice_alignment_container.queue_sort()

	await get_tree().process_frame
