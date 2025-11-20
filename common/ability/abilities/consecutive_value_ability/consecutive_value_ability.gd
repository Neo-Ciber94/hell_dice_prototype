class_name ConsecutiveValueAbility
extends AbilityData

@export var consecutives: int = 3;

var _consecutive_values_count: int = 0;

func on_roll_start(_ctx: BoardContext) -> void:
	_consecutive_values_count = 0
	
func on_roll_finished(ctx: BoardContext) -> void:
	var values: Array[int] = []
	
	for dice in ctx.dices:
		values.push_back(dice.get_dice_value())
		
	values.sort()
	
	if values.is_empty():
		return;
		
	var prev: int = values[0]
	var consecutive_counter = 0;
	
	for idx in range(1, values.size()):
		var cur = values.get(idx)
		
		if cur == (prev + 1):
			consecutive_counter += 1;
			
			if consecutive_counter >= consecutives:
				_consecutive_values_count += 1;
				consecutive_counter = 0;
		else:
			consecutive_counter = 0;
	
func calculate_score(ctx: BoardContext, accumulated_score: int) -> int:
	return accumulated_score;
