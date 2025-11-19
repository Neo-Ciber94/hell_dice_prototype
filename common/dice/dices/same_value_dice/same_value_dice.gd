@tool
class_name SameValueDice
extends Dice

@export var value: int = 1;
@export var sides: int = 6;

func get_dice_sides() -> Array[DiceSide]:
	var result: Array[DiceSide] = []
	
	for idx in sides:
		result.push_back(DiceSide.new(value, str(value)))
	
	return result;
	
func get_dice_value() -> int:
	return value;
	
func roll_dice(_rng: RNG) -> void:
	pass

func calculate_dice_score(_ctx: BoardContext, accumulated_score: int) -> int:
	return accumulated_score + value;
