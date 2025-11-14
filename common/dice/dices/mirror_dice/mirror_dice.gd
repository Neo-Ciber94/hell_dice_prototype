@tool
class_name MirrorDice
extends Dice

@export var sides: int = 6;
var _value: int = 0;
var _has_value: bool = false;

func on_roll_finished(board: Board) -> void:
	for dice_ui in board.dices_ui:
		if dice_ui is DiceUI:
			_value = max(dice_ui.dice.get_dice_value(), _value) 

	_has_value = true;
	changed.emit()

func roll_dice(_rng: RNG) -> void:
	pass
	
func get_dice_sides() -> Array[DiceSide]:
	var values: Array[DiceSide] = []
	values.resize(sides)
	
	if _has_value:
		values.fill(DiceSide.new(_value, "%s" % _value))
	else:
		values.fill(DiceSide.new(_value, ""))
		
	return values;

func calculate_dice_score(_board: Board, accumulated_score: int) -> int:
	return accumulated_score + _value;

func get_dice_value() -> int:
	return _value;

func get_dice_order() -> Order:
	return Order.EARLY
