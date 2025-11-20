class_name BonusOnDiceValueAbility
extends AbilityData

@export var value: int = 1;
@export var bonus_score: int = 1;

func on_roll_start(_ctx: BoardContext) -> void:
	pass
	
func on_roll_finished(ctx: BoardContext) -> void:
	pass
	
func calculate_score(ctx: BoardContext, accumulated_score: int) -> int:
	var total = _get_total_values_count(ctx)
	var result = total * bonus_score;
	return accumulated_score + result;

func _get_total_values_count(ctx: BoardContext) -> int:
	var total: int = 0;
	
	for dice in ctx.dices:
		if dice.get_dice_value() == value:
			total += 1;
			
	return total;
