class_name GameClient
extends Node

const MIN_DICES = 10;
const MIN_SIDE_DICES = 7;
const MIN_HAND_DICES = 6;

enum PlayerController {
	HUMAN,
	DEMON
}

signal on_damaged()
signal on_dice_roll_end()
signal on_damage_calculation_finished()
signal on_dead()
signal on_side_dices_changed(dices: Array[Dice])
signal on_choose_roll_dices(dices: Array[Dice])

@export var bag_dices: Array[Dice] = []
@export var player_health: int = 100;
@export var controller = PlayerController.HUMAN

@export_group("Demon")
@export var demon: CharlotteDemon;

var side_dices: Array[Dice] = []
var hand_dices: Array[Dice] = []

var _is_playing: bool = false;
var last_damage: int = 0;

func _ready() -> void:
	assert(bag_dices.size() >= MIN_DICES)

func play() -> void:
	_is_playing = true;
	
	match controller:
		PlayerController.HUMAN:
			pass
		PlayerController.DEMON:
			_play_demon_turn()

func _play_demon_turn() -> void:
	var rng = RNG.new(); # Use a centralized RNG?
	var result = rng.take_random_array(side_dices, MIN_HAND_DICES);
	var dices: Array[Dice] = []
	dices.append_array(result)
	
	assert(result.size() > 0)
	
	on_choose_roll_dices.emit(dices)
	bag_dices.append_array(dices)
	_is_playing = false;
	
func set_dices_to_roll(dices: Array[Dice]) -> void:
	if not _is_playing || controller != PlayerController.HUMAN:
		return;
		
	assert(dices.size() == MIN_HAND_DICES);
	assert(_has_side_dices(dices))
		 
	# Remove sides from side
	for dice in dices:
		side_dices.erase(dice)
		bag_dices.push_back(dice)
	
	on_side_dices_changed.emit(side_dices)
	
	# Notify
	on_choose_roll_dices.emit(dices)
	_is_playing = false;

func _has_side_dices(dices: Array[Dice]) -> bool:
	for dice in dices:
		if not side_dices.has(dice):
			return false;
	
	return true;

func prepare_dices(rng: RNG) -> void:	
	while side_dices.size() < MIN_SIDE_DICES and bag_dices.size() > 0:
		var d = rng.take_random(bag_dices)
		side_dices.push_back(d)

	on_side_dices_changed.emit(side_dices)

func start_turn() -> void:
	match controller:
		PlayerController.DEMON:
			demon.start_turn()
	
func end_turn() -> void:
	match controller:
		PlayerController.DEMON:
			demon.end_turn()

func take_damage(amount: int) -> void:
	print("%s took %s damage" % [name, amount])
	player_health -= amount;
	on_damaged.emit()
	last_damage = amount;
	
	if is_dead():
		on_dead.emit()

func is_dead() -> bool:
	return player_health <= 0;

func emit_dice_roll_end() -> void:
	on_dice_roll_end.emit()
	
func emit_damage_calculation_finished() -> void:
	on_damage_calculation_finished.emit()
