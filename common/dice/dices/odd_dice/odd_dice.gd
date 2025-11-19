@tool
class_name OddDice
extends Dice

@export var values = [1, 2, 3, 4, 5, 6]

var _value: int = 0;

func get_dice_sides() -> Array[DiceSide]:
	var result: Array[DiceSide] = []
	
	for val in values:
		result.push_back(DiceSide.new(val, str(val)))
	
	return result;

func roll_dice(rng: RNG) -> void:
	_value = rng.pick_random(values)
	
func get_dice_value() -> int:
	return _value;
	
func calculate_dice_score(_ctx: BoardContext, accumulated_score: int) -> int:
	return accumulated_score + _value;
