@abstract
class_name AbilityData
extends Resource

@export var ability_name: String;
@export_multiline var ability_description: String;

@abstract
func on_roll_start(board: Board) -> void;

@abstract
func on_roll_finished(board: Board) -> void;

@warning_ignore_start("unused_parameter")
func calculate_score(board: Board, accumulated_score: int) -> int:
	return accumulated_score;

func get_order() -> Dice.Order:
	return Dice.Order.FIRST;
