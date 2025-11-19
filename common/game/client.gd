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

func _ready() -> void:
	assert(bag_dices.size() >= MIN_DICES)

func play() -> void:
	_is_playing = true;
	
	match controller:
		PlayerController.HUMAN:
			pass
		PlayerController.DEMON:
			var rng = RNG.new(); # Use a centralized RNG?
			var dices = rng.take_random_array(side_dices, MIN_HAND_DICES);
			on_choose_roll_dices.emit(dices)
			_is_playing = false;

func set_dices_to_roll(dices: Array[Dice]) -> void:
	if not _is_playing || controller != PlayerController.HUMAN:
		return;
		
	assert(dices.size() == MIN_HAND_DICES);
	on_choose_roll_dices.emit(dices)
	_is_playing = false;

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
	player_health -= amount;
	on_damaged.emit()
	
	if is_dead():
		on_dead.emit()

func is_dead() -> bool:
	return player_health <= 0;
