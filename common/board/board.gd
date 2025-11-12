class_name Board
extends Control

@onready var dice_container: HBoxContainer = %DiceContainer
@onready var roll_dice_button: Button = %RollDiceButton
@onready var score_label: RichTextLabel = %ScoreLabel
@onready var game_over_screen: GameOverScreen = $GameOverScreen
@onready var win_screen: WinScreen = $WinScreen

@onready var current_score_label: Label = %CurrentScoreLabel
@onready var current_score_timer: Timer = $CurrentScoreTimer
@onready var throw_left_label: RichTextLabel = %ThrowLeftLabel

var dices: Array[Dice] = []

@export var target_score: int = 100;
@export var throws_available: int = 5;

var total_score: int = 0;
var _is_calculating_score: bool = false;
var _dice_rolling_count: int = 0;
var _remaining_throws: int = 0;

var no_more_throws: bool:
	get: return _remaining_throws == 0;

var has_reached_score: bool:
	get: return total_score >= target_score;

func _ready() -> void:
	current_score_label.hide()

	for child in dice_container.get_children():
		if child is Dice:
			dices.push_back(child)
			
	_reset_game_state()
	win_screen.on_next_run.connect(_on_next_run)
	roll_dice_button.pressed.connect(_on_roll_dices_pressed)
	
func _reset_game_state() -> void:
	_remaining_throws = throws_available
	
	_on_update_score(0)
	_update_throw_left()
	
func _on_roll_dices_pressed() -> void:
	if _is_calculating_score || no_more_throws:
		return;
		
	_remaining_throws -= 1;
	_update_throw_left()
	_roll_dices()

func _on_next_run() -> void:
	if _remaining_throws > 0:
		return;

	target_score += 50;
	throws_available += 2;
	_reset_game_state()

func _update_throw_left() -> void:
	throw_left_label.text = str(_remaining_throws)

func _check_game_state() -> void:
	if _remaining_throws > 0:
		return;
		
	if not has_reached_score:
		game_over_screen.show()
	else:
		win_screen.show_total_score(total_score, target_score)

func _roll_dices() -> void:
	current_score_label.hide()

	var rng = RNG.new()
	for idx in dices.size():
		var dice = dices.get(idx) as Dice;
		var duration = rng.randf_range(0.3, 1.0)
		dice.duration = duration;
		dice.on_finished.connect(_on_roll_finished, Object.CONNECT_ONE_SHOT)
		dice.roll_dice(rng)

func _get_current_score() -> int:
	var score: int = 0;
	
	for dice in dices:
		score += dice.get_dice_value()
	
	return score;
	
func _calculate_total_score() -> void:
	total_score += _get_current_score()

func _on_roll_finished() -> void:
	_dice_rolling_count += 1;
	
	if _dice_rolling_count == dices.size():
		_dice_rolling_count = 0;
		_show_total_score()

func _show_total_score() -> void:
	_is_calculating_score = true;
	await _bring_dices_to_front()
	_show_current_score()
	
	var initial_score = total_score;
	_calculate_total_score()
	
	score_label.show()
	score_label.text = str(initial_score)
	var tween = create_tween()
	tween.tween_method(_on_update_score, initial_score, total_score, 0.5);
	
	await tween.finished;
	_check_game_state()
	_is_calculating_score = false;
	
func _bring_dices_to_front() -> void:
	for dice in dices:
		await dice.bring_to_front()
	
func _show_current_score() -> void:
	current_score_timer.stop()
	var current_score = _get_current_score();
	current_score_label.text = "+%s" % current_score;
	current_score_label.show()
	
	current_score_timer.start(5.0);
	current_score_timer.timeout.connect(func(): current_score_label.hide(), Object.CONNECT_ONE_SHOT)
	
func _on_update_score(new_value: int) -> void:
	score_label.text = "{current} / {target}".format({
		current = new_value,
		target = target_score
	})
