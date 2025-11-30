class_name GameServer2
extends Node

enum PlayerTurn {
	P1,
	P2
}

enum TurnPhase {
	PREPARING,
	PLAYING,
	DAMAGE,
	TURN_END,
	FINISHED
}

signal on_player_turn_started(player: PlayerTurn)
signal on_player_score(player: PlayerTurn, score: int)

@export var p1: GameClient2;
@export var p2: GameClient2;

var _rng: RNG = RNG.new()
var _p1_score: int = 0;
var _p2_score: int = 0;

var _active_player: PlayerTurn = PlayerTurn.P1;
var _turn_phase: TurnPhase = TurnPhase.PREPARING;
var _turn_count: int = 1;
var _player_roll_counter: int = 0;

func start() -> void:
	_p1_score = 0;
	_p2_score = 0;
	_turn_count = 1;
	_set_turn_player(_active_player)
	
func roll_dices(dices: Array[DiceData]) -> void:
	assert(_turn_phase in [TurnPhase.TURN_END, TurnPhase.PREPARING])
	_set_turn_phase(TurnPhase.PLAYING);
	dices.sort_custom(sort_dices)
	
	var ctx = DiceContext.new(dices)
	
	for dice in dices:
		_rng_roll_dice(dice)
	
	for dice in dices:
		dice.calculate_score(ctx)
		
	for dice in dices:
		dice.on_roll_finished(ctx)
		
	_set_player_score(get_turn_player(), ctx.score)
	on_player_score.emit(get_turn_player(), ctx.score)
	_player_roll_counter += 1;
	
	_deal_damage()
	_end_turn()
	
func _rng_roll_dice(dice: DiceData) -> void:
	var sides = dice.get_dice_sides();
	var base_weight = 1.0 / sides.size();
	var weights = PackedFloat32Array()
	
	for side in sides:
		if side.side_weight < 0:
			weights.push_back(base_weight)
		else:
			weights.push_back(side.side_weight)
			
	var side_index = _rng.rand_weighted(weights)
	var selected = sides.get(side_index) as DiceSide;
	dice.set_selected_dice_side(selected)
		
	
func _deal_damage() -> void:
	if _player_roll_counter < 2:
		return;
		
	assert(_turn_phase in [TurnPhase.PLAYING])
	_player_roll_counter = 0;
	_set_turn_phase(TurnPhase.DAMAGE)
	
	if _p1_score == _p2_score:
		return;

	if _p1_score > _p2_score:
		var damage = _p1_score - _p2_score;
		p2.take_damage(damage)
	else:
		var damage = _p2_score - _p1_score;
		p1.take_damage(damage)
		
	if p1.is_dead() || p2.is_dead():
		_set_turn_phase(TurnPhase.FINISHED)
	
func _end_turn() -> void:
	if _turn_phase == TurnPhase.FINISHED:
		return;
		
	assert(_turn_phase in [TurnPhase.DAMAGE, TurnPhase.PLAYING])
	_set_turn_phase(TurnPhase.TURN_END)
	
	_p1_score = 0;
	_p2_score = 0;
	_turn_count += 1;
	
	_set_turn_player(_get_opposite_player())
	_set_turn_phase(TurnPhase.PLAYING)

func _get_opposite_player() -> PlayerTurn:
	match _active_player:
		PlayerTurn.P1: return PlayerTurn.P2;
		PlayerTurn.P2: return PlayerTurn.P1;
		_:
			assert(false, "Reachable")
			return PlayerTurn.P1;

func _set_turn_player(player: PlayerTurn) -> void:
	_active_player = player;
	on_player_turn_started.emit(_active_player)
	print("Player: %s" % PlayerTurn.find_key(player))
	
func _set_turn_phase(phase: TurnPhase) -> void:
	_turn_phase = phase;
	print("Phase: %s" % TurnPhase.find_key(phase))
	
func _set_player_score(player: PlayerTurn, score: int) -> void:
	match player:
		PlayerTurn.P1:
			_p1_score = score;
		PlayerTurn.P2:
			_p2_score = score;
			
func get_client_for_player(player: PlayerTurn) -> GameClient2:
	match player:
		PlayerTurn.P1: return p1;
		PlayerTurn.P2: return p2;
		_: return null;
		
func get_turn_client() -> GameClient2:
	return get_client_for_player(_active_player)
		
func get_turn_player() -> PlayerTurn:
	return _active_player;
		
static func sort_dices(a: DiceData, b: DiceData) -> bool:
	return a.get_order() < b.get_order()
