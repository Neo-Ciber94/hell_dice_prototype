class_name DiceRollBoard
extends Control

enum State {
	IDLE,
	ROLLING,
	SELECTING_DICE
}

const DICE_UI = preload("uid://ynjdjcukvk4c")

signal on_score_changed(new_value: int)
signal on_accumulated_score_changed(new_value: int)
signal on_round_changed(new_value: int)
signal on_rolls_left_changed(new_value: int)

@onready var roll_dice_button: Button = %RollDiceButton
@onready var center_marker: Marker2D = $CenterMarker
@onready var dice_spawn_points: Control = $DiceSpawnPoints
@onready var board: Node = %Board
@onready var dice_alignment_container: HBoxContainer = %DiceAlignmentContainer
@onready var accumulated_score_label: Label = %AccumulatedScoreLabel
@onready var score_label: RichTextLabel = %ScoreLabel
@onready var current_round_label: RichTextLabel = %CurrentRoundLabel
@onready var rolls_left_label: RichTextLabel = %RollsLeftLabel
@onready var dice_selection_screen: DiceSelectionScreen = $DiceSelectionScreen
@onready var game_over_screen: GameOverScreen = $GameOverScreen
@onready var win_screen: WinScreen = $WinScreen
@onready var accumulated_score_timer: Timer = $AccumulatedScoreTimer

@export var dices: Array[Dice] = []
@export var abilities: Array[AbilityData] = []
@export var target_score: int = 100;
@export var rolls_per_round: int = 6;

var _current_round: int = 1;
var _current_score: int = 0;
var _current_rolls: int = 0;
var _state = State.IDLE

var _board_dices: Array[DiceUI] = []
var _dice_rolling_count: int = 0;

var _score_tween: Tween;

func _ready() -> void:
	roll_dice_button.pressed.connect(roll_dices)
	on_score_changed.connect(_on_score_changed)
	on_accumulated_score_changed.connect(_on_accumulated_score_changed)
	on_round_changed.connect(_on_round_changed)
	on_rolls_left_changed.connect(_on_rolls_left_changed)
	dice_selection_screen.on_selection_done.connect(_on_dice_selection_done)
	win_screen.on_next_run.connect(_next_round)
	accumulated_score_timer.timeout.connect(_hide_accumulated_score)
	
	accumulated_score_label.hide()
	_current_rolls = rolls_per_round;
	
	_on_score_changed(_current_score, false)
	_on_round_changed(_current_round)
	_on_rolls_left_changed(rolls_per_round)

func _input(event: InputEvent) -> void:
	if event.is_released() and event is InputEventKey:
		var key_event = event as InputEventKey;
		if key_event.keycode == KEY_U:
			_state = State.SELECTING_DICE;
			dice_selection_screen.show_dice_selection(_get_mock_board())

func _on_round_changed(new_value: int) -> void:
	_current_round = new_value;
	current_round_label.text = str(new_value)
	
func _on_rolls_left_changed(new_value: int) -> void:
	_current_rolls = new_value;
	rolls_left_label.text = str(new_value)

func _on_dice_selection_done(new_dices: Array[Dice]) -> void:
	if _state != State.SELECTING_DICE:
		return;
		
	_state = State.IDLE;
	dices = new_dices;

func _on_score_changed(new_value: int, animate: bool = true) -> void:
	if animate:
		if _score_tween:
			_score_tween.stop()
			
		_score_tween = create_tween()
		
		var score_callback = func(val: int):
			_set_score(val)
			
		_score_tween.tween_method(score_callback, _current_score, new_value, 0.5);
	else:
		_set_score(new_value)

func _set_score(score: int) -> void:
	_current_score = score;
	
	if score > target_score:
		score_label.text = "[color=yellow][wave]${current}[/wave][/color] / ${target}".format({
			current = score,
			target = target_score
		})
	else:
		score_label.text = "${current} / ${target}".format({
			current = score,
			target = target_score
		})

func _on_accumulated_score_changed(new_value: int) -> void:
	accumulated_score_label.text = "+%s" % new_value;
	
func roll_dices() -> void:
	if _current_rolls <= 0:
		return;
		
	if _state != State.IDLE:
		return;
		
	_state = State.ROLLING
	for d in _board_dices:
		d.queue_free()
		
	_board_dices.clear()
	accumulated_score_label.hide()
	roll_dice_button.hide()
	
	on_rolls_left_changed.emit(_current_rolls - 1)
	
	var spawn_point = dice_spawn_points.get_children().pick_random() as Marker2D;
	var dir = spawn_point.global_position.direction_to(center_marker.global_position)
	_dice_rolling_count = dices.size()
	
	var rng = RNG.new();
	var board_mock = _get_mock_board()
	
	for dice in dices:
		var board_dice = DICE_UI.instantiate() as DiceUI;
		_board_dices.push_back(board_dice)
		board_dice.dice = dice;
		board.add_child(board_dice)
		board_dice.freeze = true;
		board_dice.dice.on_roll_start(board_mock)
		board_dice.global_position = spawn_point.global_position + Vector2(
			randf_range(-1, 1),
			randf_range(-1, 1)
		)
		
	for board_dice in _board_dices:
		board_dice.freeze = false;
		board_dice.roll_dice_to_dir(rng, dir)
		board_dice.on_finished.connect(_on_dice_finished_rolling)

func _on_dice_finished_rolling() -> void:
	_dice_rolling_count -= 1;
	
	if _dice_rolling_count <= 0:
		await _align_dices()
		await _on_roll_finished()
		roll_dice_button.show()

func _on_roll_finished() -> void:
	await _on_show_score()
	
	var has_won = _can_go_next_round()
	
	if _current_rolls == 0:
		if has_won:
			win_screen.show_total_score(_current_score, target_score)
		else:
			await get_tree().create_timer(2.0).timeout
			game_over_screen.show()
	else:
		_state = State.IDLE

func _next_round() -> void:
	if not _can_go_next_round():
		return;
		
	_on_round_changed(_current_round + 1)
	
	target_score += 10 * _current_round;

	_state = State.SELECTING_DICE
	dice_selection_screen.show_dice_selection(_get_mock_board())
	_on_rolls_left_changed(rolls_per_round)
	_set_score(0);
	
func _can_go_next_round() -> bool:
	return _current_score >= target_score;

func _on_show_score() -> void:
	var score: int = 0;
	var board_mock = _get_mock_board()
	accumulated_score_timer.stop()
	
	_board_dices.sort_custom(_sort_dices)
	
	for board_dice in _board_dices:
		board_dice.dice.on_roll_finished(board_mock)
	
	for board_dice: DiceUI in _board_dices:
		var dice = board_dice.dice;		
		score = board_dice.dice.calculate_dice_score(board_mock, score)
		accumulated_score_label.show()
		on_accumulated_score_changed.emit(score)
		await board_dice.bring_to_front()

	on_score_changed.emit(_current_score + score)
	accumulated_score_timer.start(2.0)

func _hide_accumulated_score() -> void:
	accumulated_score_label.hide()

func _align_dices() -> void:
	const DURATION = 0.5;

	_prepare_align_markers()

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

# this is for keep the prev impl
func _get_mock_board() -> Board:
	var b = Board.new()
	b.dices_ui = _board_dices;
	return b;

func _sort_dices(a: DiceUI, b: DiceUI) -> bool:
	return a.dice.get_dice_order() < b.dice.get_dice_order()
	
func _sort_abilities(a: AbilityData, b: AbilityData) -> bool:
		return a.get_order() < b.get_order()
