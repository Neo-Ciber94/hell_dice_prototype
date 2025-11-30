class_name D6Dice
extends DiceData

@export var side_1: int = 1;
@export var side_2: int = 2;
@export var side_3: int = 3;
@export var side_4: int = 4;
@export var side_5: int = 5;
@export var side_6: int = 6;

var sides: Array[int]:
	get: return [
		side_1,
		side_2,
		side_3,
		side_4,
		side_5,
		side_6,
	]

var _value: int = 0;

func get_dice_sides() -> Array[DiceSide]:
	var result: Array[DiceSide] = []
	
	for idx in sides:
		result.push_back(DiceSide.new(idx, str(idx)))
	
	return result;

func get_selected_dice_side() -> DiceSide:
	return get_dice_sides_as_map().get(_value)
	
func set_selected_dice_side(side: DiceSide) -> void:
	_value = side.side_value;
	
func calculate_score(ctx: DiceContext) -> void:
	ctx.score += _value;
