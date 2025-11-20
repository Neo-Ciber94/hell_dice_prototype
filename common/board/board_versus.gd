class_name BoardVersus
extends Control

@onready var game_server: GameServer = $GameServer
@onready var human_player: GameClient = $GameServer/HumanPlayer
@onready var demon_player: GameClient = $GameServer/DemonPlayer

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
@onready var damage_overlay: DamageOverlay = $DamageOverlay

@onready var opponent_hp_label: RichTextLabel = %OpponentHPLabel
@onready var player_hp_label: RichTextLabel = %PlayerHPLabel

@onready var center_point: Marker2D = $CenterPoint

var _money: int = 0;
var _board_dices: Array[DiceUI] = []
var _rolling_dice_count: int = 0;

func _ready() -> void:
	roll_dice_button.hide()
	player_score_label.hide()
	opponent_score_label.hide()
	damage_label.hide()

	roll_dice_button.pressed.connect(_on_roll_dices_pressed)
	hand_dices_container.on_changed.connect(_on_hand_dice_changed)
	game_server.on_roll_dices.connect(_on_roll_dices)
	
	human_player.on_damaged.connect(_on_player_damaged.bind(GameServer.TurnPlayer.P1))
	demon_player.on_damaged.connect(_on_player_damaged.bind(GameServer.TurnPlayer.P2))
	
	_set_money(0, false)
	
	# Start the game
	human_player.on_side_dices_changed.connect(_on_player_side_dices_changed)
	game_server.on_turn_player_changed.connect(_on_turn_player_changed)
	game_server.start.call_deferred()
	
func _set_money(value: int, animate: bool = true) -> void:
	if animate:
		var tween = create_tween()
		tween.tween_method(func(val: int): money_label.text = "$%s" % val, _money, value, 0.5)
	else:
		money_label.text =" $%s" % value
		
	_money = value;

func _set_health(amount: int, turn_player: GameServer.TurnPlayer) -> void:
	match turn_player:
		GameServer.TurnPlayer.P1:
			player_hp_label.text = "{cur} / 100".format({ 
				cur = amount
			})
		GameServer.TurnPlayer.P2:
			opponent_hp_label.text  = "{cur} / 100".format({ 
				cur = amount
			})

func _update_health(player: GameServer.TurnPlayer) -> void:
	var p = game_server.get_client_for_player(player)
	_set_health(p.player_health, player)

func _on_player_side_dices_changed(dices: Array[Dice]) -> void:
	side_dices_container.set_dices(dices)

func _on_hand_dice_changed(dices: Array[Dice]) -> void:
	roll_dice_button.visible = dices.size() >= GameClient.MIN_HAND_DICES
	_set_hand_dice_count(dices.size())

func _set_hand_dice_count(value: int) -> void:
	current_dice_count.text = "{cur} / {min}".format({
		cur = value,
		min = GameClient.MIN_HAND_DICES
	})

func _on_roll_dices_pressed() -> void:
	if game_server.get_turn_player() == GameServer.TurnPlayer.P1:
		roll_dice_button.hide()
		var selected_dices = hand_dices_container.take_all_dices()
		human_player.set_dices_to_roll(selected_dices)

func _clear_dices() -> void:
	for board_dice in _board_dices:
		board_dice.queue_free()
		
	_board_dices.clear()
	
func _on_roll_dices(dices_to_roll: Array[Dice]) -> void:
	const DICE_UI = preload("uid://ynjdjcukvk4c")
	var spawn_point = _get_dice_spawn_point()
	
	_clear_dices()
	hand_dices_container.show()
	current_dice_count.hide()
	
	for dice in dices_to_roll:
		var board_dice = DICE_UI.instantiate() as DiceUI;
		_board_dices.push_back(board_dice)
		
		board_dice.dice = dice;
		dice_table.add_child(board_dice)
		board_dice.freeze = true;
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
	
	if _rolling_dice_count == 0:
		await _show_accumulated_score()
		game_server.get_turn_client().emit_dice_roll_end()
	
func _show_accumulated_score() -> void:
	var label = _get_score_label()
	var dices: Array[Dice] = []
	dices.append_array(_board_dices.map(func(x: DiceUI): return x.dice))
	dices.sort_custom(GameServer.sort_dices)
	
	var score = 0;
	var ctx = BoardContext.new(dices)
		
	for dice: Dice in dices:
		score = dice.calculate_dice_score(ctx, score);
		label.text = "{sign}{score}".format({
			score = score,
			sign = "+" if score >= 0 else "" 
		});
		
		label.show()
		await get_tree().create_timer(0.5).timeout

	match game_server.get_turn_player():
		GameServer.TurnPlayer.P1:
			_set_money(_money + score)
			
	await get_tree().create_timer(1.0).timeout
	label.text = "%s" % score;

func _on_player_damaged(player: GameServer.TurnPlayer) -> void:
	await get_tree().create_timer(0.5).timeout
	var client = game_server.get_client_for_player(player)
	
	match player:
		GameServer.TurnPlayer.P1:
			_update_health(GameServer.TurnPlayer.P1)
			await damage_overlay.damaged()
			damage_label.text = "Damage: %s" % client.last_damage
			damage_label.show()
			
			human_player.emit_damage_calculation_finished()
		GameServer.TurnPlayer.P2:
			_update_health(GameServer.TurnPlayer.P2)
			await charlotte_demon.damaged()
			damage_label.text = "Damage: %s" % client.last_damage
			damage_label.show()
			
			demon_player.emit_damage_calculation_finished()
			
	player_score_label.hide()
	opponent_score_label.hide()
	
	get_tree().create_timer(2.0).timeout.connect(func(): damage_label.hide(), Object.CONNECT_ONE_SHOT)
	
func _on_turn_player_changed(player: GameServer.TurnPlayer) -> void:
	_clear_dices()
	await get_tree().create_timer(0.5).timeout
	
	match player:
		GameServer.TurnPlayer.P1:
			hand_dices_container.show()
			current_dice_count.show()
		GameServer.TurnPlayer.P2:
			roll_dice_button.hide()
	
func _animate_label(label: RichTextLabel, score: int) -> void:
	var tween = create_tween()
	tween.tween_method(func(val: int): label.text = str(val), score, 0, 0.5)
	await tween.finished
	label.hide()

func _get_score_label() -> RichTextLabel:
	match game_server.get_turn_player():
		GameServer.TurnPlayer.P1:
			return player_score_label
		GameServer.TurnPlayer.P2:
			return opponent_score_label
		_:
			return null;

func _get_dice_spawn_point() -> Marker2D:
	match game_server.get_turn_player():
		GameServer.TurnPlayer.P1:
			return player_spawn_points.get_children().pick_random()
		GameServer.TurnPlayer.P2:
			return opponent_spawn_points.get_children().pick_random()
		_:
			return null;
