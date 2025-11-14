class_name BonusOnDiceValueAbility
extends AbilityData

@export var value: int = 1;
@export var bonus_score: int = 1;

func on_roll_start(_board: Board) -> void:
	pass
	
func on_roll_finished(_board: Board) -> void:
	pass
	
func calculate_score(board: Board, accumulated_score: int) -> int:
	var total: int = 0;
	
	for dice_ui in board.dices_ui:
		if dice_ui.dice.get_dice_order() == value:
			total += 1;
			
	var result = total * bonus_score;
	return accumulated_score + result;
