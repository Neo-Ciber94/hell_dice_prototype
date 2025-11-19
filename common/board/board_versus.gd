class_name BoardVersus
extends Control

const MIN_HAND_DICES = 6;
const MIN_SIDE_DICES = 7;

enum Turn {
	Player,
	Opponent
}

@onready var charlotte_demon: CharlotteDemon = $CharlotteDemon
@onready var roll_dice_button: Button = %RollDiceButton
@onready var hand_dices_container: DiceContainer = %HandDicesContainer
@onready var side_dices_container: DiceContainer = %SideDicesContainer
@onready var money_label: RichTextLabel = %MoneyLabel
@onready var current_dice_count: RichTextLabel = %CurrentDiceCount
@onready var player_spawn_points: Node2D = $DiceTable/PlayerSpawnPoints
@onready var opponent_spawn_points: Node2D = $DiceTable/OpponentSpawnPoints
@onready var dice_table: StaticBody2D = %DiceTable
@onready var player_score_label: RichTextLabel = %PlayerScoreLabel
@onready var opponent_score_label: RichTextLabel = %OpponentScoreLabel
@onready var damage_label: RichTextLabel = %DamageLabel

@onready var opponent_hp_label: RichTextLabel = %OpponentHPLabel
@onready var player_hp_label: RichTextLabel = %PlayerHPLabel

@onready var center_point: Marker2D = $CenterPoint

@export var player_dices: Array[Dice] = []
@export var player_health: int = 100;

@export var opponent_dices: Array[Dice] = []
@export var opponent_health: int = 100;

var _player_dices: Array[Dice] = []
var _opponent_dices: Array[Dice] = []

var _money: int = 0;
var _turn_player = Turn.Player;
var _player_score: int = 0;
var _opponent_score: int = 0;

var _board_dices: Array[DiceUI] = []
var _rolling_dice_count: int = 0;

var _deck_dices: Array[Dice] = []
var _discard_dices: Array[Dice] = []

func _ready() -> void:
	roll_dice_button.hide()
	player_score_label.hide()
	opponent_score_label.hide()
	damage_label.hide()

	roll_dice_button.pressed.connect(_on_roll_dices_pressed)
	hand_dices_container.on_changed.connect(_on_hand_dice_changed)
	
	_prepare_deck()
	_draw_dices()
	_set_money(0, false)
	
func _prepare_deck() -> void:
	var dices = player_dices.duplicate()
	dices.shuffle()
	_deck_dices.append_array(dices)
	
func _draw_dices() -> void:
	var all_dices : Array[Dice] = []
	all_dices.append_array(_discard_dices)
	all_dices.append_array(_deck_dices)
	
	_discard_dices.clear()
	_deck_dices.clear()
	
	var dices: Array[Dice] = []
	all_dices.shuffle()
	
	var rng = RNG.new()
	while dices.size() < MIN_HAND_DICES and all_dices.size() > 0:
		var d = rng.take_random(all_dices)
		dices.push_back(d)
	
	side_dices_container.set_dices(dices)
	
func _set_money(value: int, animate: bool = true) -> void:
	if animate:
		var tween = create_tween()
		tween.tween_method(func(val: int): money_label.text = "$%s" % val, _money, value, 0.5)
	else:
		money_label.text =" $%s" % value
		
	_money = value;

func _take_damage(damage: int, turn_player: Turn) -> void:
	match turn_player:
		Turn.Player:
			player_health = max(0, player_health + damage)
			_set_health(player_health, turn_player)
		Turn.Opponent:
			opponent_health = max(0, opponent_health + damage)
			_set_health(opponent_health, turn_player)

func _set_health(amount: int, turn_player: Turn) -> void:
	match turn_player:
		Turn.Player:
			player_hp_label.text = "{cur} / 100".format({ 
				cur = amount
			})
		Turn.Opponent:
			opponent_hp_label.text  = "{cur} / 100".format({ 
				cur = amount
			})

func _on_hand_dice_changed(dices: Array[Dice]) -> void:
	roll_dice_button.visible = dices.size() >= MIN_HAND_DICES
	_set_hand_dice_count(dices.size())

func _set_hand_dice_count(value: int) -> void:
	current_dice_count.text = "{cur} / {min}".format({
		cur = value,
		min = MIN_HAND_DICES
	})

func _on_roll_dices_pressed() -> void:
	if _turn_player == Turn.Player:
		roll_dice_button.hide()
		_roll_dices()

func _clear_dices() -> void:
	for board_dice in _board_dices:
		board_dice.queue_free()
		
	_board_dices.clear()
	
func _roll_dices() -> void:
	if player_health == 0 || opponent_health == 0:
		return;
		
	const DICE_UI = preload("uid://ynjdjcukvk4c")
	
	var spawn_point = _get_dice_spawn_point()
	var dices_to_roll = _get_hand_dices()
	var ctx = BoardContext.new(dices_to_roll)
	
	hand_dices_container.show()
	current_dice_count.hide()
	_clear_dices()
	
	for dice in dices_to_roll:
		var board_dice = DICE_UI.instantiate() as DiceUI;
		_board_dices.push_back(board_dice)
		
		board_dice.dice = dice;
		dice_table.add_child(board_dice)
		board_dice.freeze = true;
		board_dice.dice.on_roll_start(ctx)
		board_dice.global_position = spawn_point.global_position + Vector2(
			randf_range(-1, 1),
			randf_range(-1, 1)
		)
		
	var dir = spawn_point.global_position.direction_to(center_point.global_position)
	var rng = RNG.new();

	for board_dice in _board_dices:
		_rolling_dice_count += 1;
		board_dice.freeze = false;
		board_dice.on_finished.connect(_on_dice_finished_roll)
		board_dice.roll_dice_to_dir(rng, dir)
		
func _on_dice_finished_roll() -> void:
	_rolling_dice_count -= 1;
	
	if _rolling_dice_count <= 0:
		await _show_accumulated_score()
		await _end_turn()
		await _start_turn()
	
func _show_accumulated_score() -> void:
	var label = _get_score_label()
	var dices: Array[Dice] = []
	dices.append_array(_board_dices.map(func(x: DiceUI): return x.dice))
	dices.sort_custom(_sort_dices)
	
	var score = 0;
	var ctx = BoardContext.new(dices)
		
	for dice: Dice in dices:
		score = dice.calculate_dice_score(ctx, score);
		label.text = "+%s" % score;
		label.show()
		await get_tree().create_timer(0.5).timeout

	match _turn_player:
		Turn.Player:
			_player_score = score;
			_set_money(_money + score)
		Turn.Opponent:
			_opponent_score = score;
			
	await get_tree().create_timer(1.0).timeout
	label.text = "%s" % score;

var _turn_count: int = 1;

func _end_turn() -> void:
	_turn_count += 1;
	
	if _turn_count % 2 == 0:
		await _animate_label(player_score_label, _player_score)
		await _animate_label(opponent_score_label, _opponent_score)
		await _apply_damage()
		
	# Switch player
	match _turn_player:
		Turn.Player:
			_turn_player = Turn.Opponent
			charlotte_demon.start_turn()
		Turn.Opponent:
			_turn_player = Turn.Player;
			charlotte_demon.end_turn();
		
	await get_tree().create_timer(0.5).timeout
	_clear_dices()
	
func _start_turn() -> void:
	await get_tree().create_timer(0.5).timeout
	
	# Player
	match _turn_player:
		Turn.Player:
			roll_dice_button.show()
			hand_dices_container.show()
			current_dice_count.show()
			_draw_dices()
		Turn.Opponent:
			roll_dice_button.hide()
			_roll_dices()
	
func _animate_label(label: RichTextLabel, score: int) -> void:
	var tween = create_tween()
	tween.tween_method(func(val: int): label.text = str(val), score, 0, 0.5)
	await tween.finished
	label.hide()
	
func _apply_damage() -> void:	
	if _player_score == _opponent_score:
		return;
		
	if _player_score > _opponent_score:
		var damage = _opponent_score - _player_score;
		damage_label.text = "damage: %s" % damage;
		_take_damage(damage, Turn.Opponent)
	else:
		var damage = _player_score - _opponent_score;
		damage_label.text = "damage: %s" % damage;
		_take_damage(damage, Turn.Player)
		
	_player_score = 0
	_opponent_score = 0;
	
	await get_tree().create_timer(1.0).timeout
	damage_label.hide()
	
	if player_health == 0:
		print("You lose")
		
	if opponent_health == 0:
		print("You win")
	
func _get_score_label() -> RichTextLabel:
	match _turn_player:
		Turn.Player:
			return player_score_label
		Turn.Opponent:
			return opponent_score_label
		_:
			return null;
		
func _get_hand_dices() -> Array[Dice]:
	match _turn_player:
		Turn.Player:
			var dices = hand_dices_container.remove_all_dices()
			_discard_dices.append_array(dices)
			return dices;
		Turn.Opponent:
			var rng = RNG.new()
			var dices: Array[Dice] = []
			var available_dices = opponent_dices.duplicate()
			
			while available_dices.size() > 0 and dices.size() < MIN_HAND_DICES:
				dices.push_back(rng.take_random(available_dices))
				
			return dices
		_:
			return [];

func _get_dice_spawn_point() -> Marker2D:
	match _turn_player:
		Turn.Player:
			return player_spawn_points.get_children().pick_random()
		Turn.Opponent:
			return opponent_spawn_points.get_children().pick_random()
		_:
			return null;

static func _sort_dices(a: Dice, b: Dice) -> bool:
	return a.get_dice_order() < b.get_dice_order()
