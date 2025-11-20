@abstract
class_name AbilityData
extends Resource

@export var ability_name: String;
@export_multiline var ability_description: String;

func on_calculating_score(ctx: BoardContext) -> void:
	pass

@abstract
func on_roll_start(ctx: BoardContext) -> void;

@abstract
func on_roll_finished(ctx: BoardContext) -> void;

@warning_ignore_start("unused_parameter")
func calculate_score(ctx: BoardContext, accumulated_score: int) -> int:
	return accumulated_score;

func get_order() -> Dice.Order:
	return Dice.Order.FIRST;
