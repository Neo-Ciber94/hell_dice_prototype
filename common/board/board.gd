class_name Board
extends Control

@onready var dice_container: HBoxContainer = %DiceContainer
@onready var roll_dice_button: Button = %RollDiceButton
@onready var score_label: RichTextLabel = %ScoreLabel
@onready var game_over_screen: GameOverScreen = $GameOverScreen
@onready var win_screen: WinScreen = $WinScreen
@onready var dice_selection_screen: DiceSelectionScreen = $DiceSelectionScreen

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
	dice_selection_screen.on_selection_done.connect(_on_selection_done)

func _reset_game_state() -> void:
	_remaining_throws = throws_available
	
	_on_update_score(0)
	_update_throw_left()
	
func _on_selection_done(behaviours: Array[DiceBehaviour]) -> void:
	for idx in behaviours.size():
		var dice = dices[idx] as Dice;
		dice.behaviour = behaviours.get(idx)
		dice._prepare()
	
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
	current_score_label.hide()
	_reset_game_state()

func _input(event: InputEvent) -> void:
	if event.is_released() and event is InputEventKey:
		var key_event = event as InputEventKey;
		if key_event.keycode == KEY_U:
			dice_selection_screen.show_dice_selection(self)

func _update_throw_left() -> void:
	throw_left_label.text = str(_remaining_throws)

func _check_game_state() -> void:
	if _remaining_throws > 0:
		dice_selection_screen.show_dice_selection(self)
		return;
		
	if not has_reached_score:
		game_over_screen.show()
	else:
		win_screen.show_total_score(total_score, target_score)
		
	# TODO: Remove
	for dice in dices:
		dice._had_rolled = false;

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
	var cur_score: int = 0;
	var cur_dices = dices.duplicate();
	cur_dices.sort_custom(_sort_dices)
	
	for dice in dices:
		cur_score = dice.behaviour.calculate_dice_score(self, cur_score)
	
	return cur_score;
	
func _sort_dices(a: Dice, b: Dice) -> bool:
	return a.behaviour.get_dice_order() < b.behaviour.get_dice_order()
	
func _calculate_total_score() -> void:
	total_score += _get_current_score()

func _on_roll_finished() -> void:
	_dice_rolling_count += 1;
	
	if _dice_rolling_count == dices.size():
		_dice_rolling_count = 0;
		_show_total_score()

func _show_total_score() -> void:
	_is_calculating_score = true;
	await _show_current_score()
	
	var initial_score = total_score;
	_calculate_total_score()
	
	score_label.show()
	score_label.text = str(initial_score)
	var tween = create_tween()
	tween.tween_method(_on_update_score, initial_score, total_score, 0.5);
	
	await tween.finished;
	_check_game_state()
	_is_calculating_score = false;
	
func _show_score_accumulation() -> void:
	# TODO: We are duplicating the entire node
	var cur_dices = dices.duplicate() as Array[Dice]
	cur_dices.sort_custom(_sort_dices)
	
	var cur_score: int = 0;
	
	for dice in cur_dices:
		await dice.bring_to_front()
		current_score_label.show()
		cur_score = dice.behaviour.calculate_dice_score(self, cur_score)
		current_score_label.text = "+%s" % cur_score;
	
func _show_current_score() -> void:
	current_score_timer.stop()	

	# Show increment
	await _show_score_accumulation()
	
	# Show result
	current_score_label.show()
	var score = _get_current_score();
	current_score_label.text = "+%s" % score;
	
	current_score_timer.start(5.0);
	current_score_timer.timeout.connect(func(): current_score_label.hide(), Object.CONNECT_ONE_SHOT)
	
func _on_update_score(new_value: int) -> void:
	score_label.text = "{current} / {target}".format({
		current = new_value,
		target = target_score
	})
