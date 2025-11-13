class_name Board
extends Control

@onready var dice_container: HBoxContainer = %DiceContainer
@onready var roll_dice_button: Button = %RollDiceButton
@onready var score_label: RichTextLabel = %ScoreLabel
@onready var game_over_screen: GameOverScreen = $GameOverScreen
@onready var win_screen: WinScreen = $WinScreen
@onready var dice_selection_screen: DiceSelectionScreen = $DiceSelectionScreen
@onready var end_round_button: Button = %EndRoundButton
@onready var current_round_label: RichTextLabel = %CurrentRoundLabel

@onready var current_score_label: Label = %CurrentScoreLabel
@onready var current_score_timer: Timer = $CurrentScoreTimer
@onready var rolls_left_label: RichTextLabel = %RollsLeftLabel

var dices_ui: Array[DiceUI] = []

@export var target_score: int = 100;
@export var rolls_available: int = 5;

var current_score: int = 0;
var _current_round: int = 1;

var _is_calculating_score: bool = false;
var _dice_rolling_count: int = 0;
var _remaining_rolls: int = 0;

var no_more_throws: bool:
	get: return _remaining_rolls == 0;

var has_reached_score: bool:
	get: return current_score >= target_score;

func _ready() -> void:
	current_score_label.hide()

	for child in dice_container.get_children():
		if child is DiceUI:
			dices_ui.push_back(child)
			
	_reset_game_state()

	win_screen.on_next_run.connect(_on_next_round)
	roll_dice_button.pressed.connect(_on_roll_dices_pressed)
	dice_selection_screen.on_selection_done.connect(_on_selection_done)
	end_round_button.pressed.connect(_on_end_round_pressed)

func _process(_delta: float) -> void:
	end_round_button.visible = _remaining_rolls > 0 and has_reached_score

func _reset_game_state() -> void:
	_remaining_rolls = rolls_available
	current_round_label.text = str(_current_round)
	current_score = 0;
	
	end_round_button.hide()
	_on_update_score(0)
	_update_throw_left()
	
func _on_end_round_pressed() -> void:
	_on_next_round()
	
func _on_selection_done(dices: Array[Dice]) -> void:
	for idx in dices.size():
		var dice_ui = dices_ui[idx] as DiceUI;
		dice_ui.dice = dices.get(idx)
		dice_ui._prepare()
	
func _on_roll_dices_pressed() -> void:
	if _is_calculating_score || no_more_throws:
		return;
		
	_remaining_rolls -= 1;
	
	_update_throw_left()
	_roll_dices()

func _on_next_round() -> void:
	#if _remaining_rolls > 0:
		#return;

	_current_round += 1;
	
	if _current_round > 3:
		_current_round = 0;
		target_score *= 10;
	else:
		dice_selection_screen.show_dice_selection(self)
		target_score += 50;
		rolls_available += 1;
	
	current_round_label.text = str(_current_round)
	current_score_label.hide()
	_reset_game_state()

func _input(event: InputEvent) -> void:
	if event.is_released() and event is InputEventKey:
		var key_event = event as InputEventKey;
		if key_event.keycode == KEY_U:
			dice_selection_screen.show_dice_selection(self)

func _update_throw_left() -> void:
	rolls_left_label.text = str(_remaining_rolls)

func _check_game_state() -> void:
	var is_game_over = _remaining_rolls == 0 and not has_reached_score
	
	if is_game_over:
		game_over_screen.show()
	elif has_reached_score:
		win_screen.show_total_score(current_score, target_score)
	else:
		pass
		
	# TODO: Remove
	for dice in dices_ui:
		dice._had_rolled = false;

func _roll_dices() -> void:
	current_score_label.hide()
	
	for dice_ui in dices_ui:
		if dice_ui is DiceUI:
			dice_ui.dice.on_roll_start(self)

	var rng = RNG.new()
	for idx in dices_ui.size():
		var dice_ui = dices_ui.get(idx) as DiceUI;
		var duration = rng.randf_range(0.3, 1.0)
		dice_ui.duration = duration;
		dice_ui.on_finished.connect(_on_roll_finished, Object.CONNECT_ONE_SHOT)
		dice_ui.roll_dice(rng)

func _get_current_score() -> int:
	var cur_score: int = 0;
	var cur_dices = dices_ui.duplicate();
	cur_dices.sort_custom(_sort_dices)
	
	for dice_ui in dices_ui:
		cur_score = dice_ui.dice.calculate_dice_score(self, cur_score)
	
	return cur_score;
	
func _sort_dices(a: DiceUI, b: DiceUI) -> bool:
	return a.dice.get_dice_order() < b.dice.get_dice_order()
	
func _calculate_total_score() -> void:
	current_score += _get_current_score()

func _on_roll_finished() -> void:
	_dice_rolling_count += 1;
	
	if _dice_rolling_count == dices_ui.size():
		_dice_rolling_count = 0;
		_on_roll_ended()
		_show_total_score()
	
func _on_roll_ended() -> void:
	for dice_ui in dices_ui:
		if dice_ui is DiceUI:
			dice_ui.dice.on_roll_finished(self)
	
func _show_total_score() -> void:
	_is_calculating_score = true;
	await _show_current_score()
	
	var initial_score = current_score;
	_calculate_total_score()
	
	score_label.show()
	score_label.text = str(initial_score)
	var tween = create_tween()
	tween.tween_method(_on_update_score, initial_score, current_score, 0.5);
	
	await tween.finished;
	_check_game_state()
	_is_calculating_score = false;

func _show_score_accumulation() -> void:
	# TODO: We are duplicating the entire node
	var cur_dices = dices_ui.duplicate() as Array[DiceUI]
	cur_dices.sort_custom(_sort_dices)
	
	var cur_score: int = 0;
	
	for dice_ui in cur_dices:
		await dice_ui.bring_to_front()
		current_score_label.show()
		cur_score = dice_ui.dice.calculate_dice_score(self, cur_score)
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
	if new_value > target_score:
		score_label.text = "[color=yellow][wave]${current}[/wave][/color] / ${target}".format({
			current = new_value,
			target = target_score
		})
	else:
		score_label.text = "${current} / ${target}".format({
			current = new_value,
			target = target_score
		})
		
