class_name GameServer
extends Node

enum TurnPlayer {
	P1,
	P2
}

enum TurnPhase {
	DECIDING,
	TURN_START,
	ROLL,
	DAMAGE,
	TURN_END,
	FINISHED
}
	
signal on_phase_change(phase: TurnPhase)
signal on_turn_player_changed(player: TurnPlayer)
signal on_roll_dices(dices: Array[Dice])
signal on_player_score(player: TurnPlayer, score: int)
signal on_game_finished(winner: TurnPlayer)
	
@export var p1: GameClient;
@export var p2: GameClient;

var _rng: RNG = RNG.new()
var _turn_player = TurnPlayer.P1;
var _turn_phase = TurnPhase.DECIDING
var _turn_count: int = 1;

var _p1_score: int = 0;
var _p2_score: int = 0;
var _player_roll_counter: int = 0;

func _ready() -> void:
	assert(p1 != null)
	assert(p2 != null)
	assert(p1 != p2)

func start() -> void:
	_prepare_players()
	await _dedice_first()
	
	while _turn_phase != TurnPhase.FINISHED:
		await _play_turn()
		_end_turn()
	
func _play_turn() -> void:
	_set_turn_phase(TurnPhase.TURN_START)
	var client = get_turn_client()
	client.start_turn()
	client.play.call_deferred()
	var dices_to_roll = await client.on_choose_roll_dices;
	
	_roll_dices(dices_to_roll)
	await client.on_dice_roll_end
	
	if _apply_damage():
		#await client.on_damage_calculation_finished
		await SignalUtils.when_any([
			p1.on_damage_calculation_finished,
			p2.on_damage_calculation_finished
		]).completed
		
	if p1.is_dead() || p2.is_dead():
		_finish_game()
	
func _end_turn() -> void:
	if _turn_phase == TurnPhase.FINISHED:
		return;
		
	_turn_count += 1;
	_set_turn_phase(TurnPhase.TURN_END)
	get_turn_client().end_turn()
		
	match _turn_player:
		TurnPlayer.P1:
			_set_turn_player(TurnPlayer.P2);
		TurnPlayer.P2:
			_set_turn_player(TurnPlayer.P1);
			
	get_turn_client().prepare_dices(_rng)
	
func _roll_dices(dices: Array[Dice]) -> void:
	var ctx = BoardContext.new(dices)
	dices = dices.duplicate()
	dices.sort_custom(sort_dices)
	
	for dice in dices:
		dice.on_roll_start(ctx)
		
	for dice in dices:
		dice.roll_dice(_rng)
		
	for dice in dices:
		dice.on_roll_finished(ctx)
		
	_player_roll_counter += 1;
	on_roll_dices.emit(dices)
	
	_calculate_score(dices)
	
func _calculate_score(dices: Array[Dice]) -> void:
	var score: int = 0;
	var ctx = BoardContext.new(dices)
	
	for dice in dices:
		score = dice.calculate_dice_score(ctx, score);
		
	on_player_score.emit(_turn_player, score)
	_set_player_score(_turn_player, score)
	
func _apply_damage() -> bool:
	if _player_roll_counter != 2:
		return false;
		
	_player_roll_counter = 0;
	
	_set_turn_phase(TurnPhase.DAMAGE)
	
	if _p1_score == _p2_score:
		_p1_score = 0;
		_p2_score = 0;
		print("No damage")
		return false;
		
	if _p1_score > _p2_score:
		var damage_amount = abs(_p2_score - _p1_score);
		p2.take_damage.call_deferred(damage_amount)
	else:
		var damage_amount = abs(_p1_score - _p2_score);
		p1.take_damage.call_deferred(damage_amount)

	_p1_score = 0;
	_p2_score = 0;
	return true;

func _finish_game() -> void:
	_set_turn_phase(TurnPhase.FINISHED)	
	
	if p1.is_dead():
		on_game_finished.emit(TurnPlayer.P2)
	elif p2.is_dead():
		on_game_finished.emit(TurnPlayer.P1)
	else:
		print("A tie which should not happen")
	
func _prepare_players() -> void:
	p1.prepare_dices(_rng)
	p2.prepare_dices(_rng)
	
func _dedice_first() -> void:
	_set_turn_phase(TurnPhase.DECIDING)
	_turn_player = TurnPlayer.P1;
	_set_turn_player(_turn_player)
	await get_tree().process_frame
	
func _set_turn_player(player: TurnPlayer) -> void:
	_turn_player = player;
	on_turn_player_changed.emit(player)
	print("Player: %s" % TurnPlayer.find_key(player))
	
func _set_turn_phase(phase: TurnPhase) -> void:
	_turn_phase = phase;
	on_phase_change.emit(phase)
	print("Phase: %s" % TurnPhase.find_key(phase))
	
func _set_player_score(player: TurnPlayer, score: int) -> void:
	match player:
		TurnPlayer.P1:
			_p1_score = score;
		TurnPlayer.P2:
			_p2_score = score;
	
func get_client_for_player(player: TurnPlayer) -> GameClient:
	match player:
		TurnPlayer.P1: return p1;
		TurnPlayer.P2: return p2;
		_: return null;
		
func get_turn_client() -> GameClient:
	return get_client_for_player(_turn_player)
		
func get_turn_player() -> TurnPlayer:
	return _turn_player;
		
static func sort_dices(a: Dice, b: Dice) -> bool:
	return a.get_dice_order() < b.get_dice_order()
