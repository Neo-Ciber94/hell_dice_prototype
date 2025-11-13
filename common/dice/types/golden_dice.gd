@tool
class_name GoldenDice 
extends Dice

@export var multipliers = [1, 2, 3, 4, 5, 6]

var _value: int = 0;

func roll_dice(rng: RNG) -> void:
	if multipliers.is_empty():
		return;
		
	_value = rng.pick_random(multipliers)
	
func get_dice_value() -> int:
	return _value;

func get_dice_order() -> Order:
	return Order.LAST

func calculate_dice_score(_board: Board, accumulated_score: int) -> int:
	return get_dice_value() * accumulated_score;
	
func get_dice_sides() -> Array[DiceSide]:
	var sides: Array[DiceSide] = []
	
	for value in multipliers:
		sides.push_back(DiceSide.new(value, "x%s" % value))
	
	return sides;
