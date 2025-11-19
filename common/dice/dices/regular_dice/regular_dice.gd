@tool
class_name RegularDice 
extends Dice

@export var dice_values: Array[int] = [1, 2, 3, 4, 5, 6]

var _value: int = 0;

func roll_dice(rng: RNG) -> void:
	if dice_values.is_empty():
		return;
		
	_value = rng.pick_random(dice_values)
	
func get_dice_value() -> int:
	return _value;

func calculate_dice_score(_ctx: BoardContext, accumulated_score: int) -> int:
	return get_dice_value() + accumulated_score;
	
func get_dice_sides() -> Array[DiceSide]:
	var sides: Array[DiceSide] = []
	
	for value in dice_values:
		sides.push_back(DiceSide.new(value, str(value)))
	
	return sides;
