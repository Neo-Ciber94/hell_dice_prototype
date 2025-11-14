@tool
class_name BankDice
extends Dice

var _value: int = 0;

func on_roll_start(_board: Board) -> void:
	_value = 0;

func on_roll_finished(board: Board) -> void:
	_value = 0;
	
	for dice_ui in board.dices_ui:
		if dice_ui.dice != self:
			_value += dice_ui.dice.get_dice_value()
		
	changed.emit()

func roll_dice(_rng: RNG) -> void:
	pass

func get_dice_value() -> int:
	return _value;

func get_dice_sides() -> Array[DiceSide]:
	var result : Array[DiceSide] = []
	result.resize(6)
	
	if _value == 0:
		result.fill(DiceSide.new(0, ""))
	else:
		result.fill(DiceSide.new(_value, str(_value)))
		
	return result;

func get_dice_order() -> Order:
	return Order.EARLY

func calculate_dice_score(_board: Board, accumulated_score: int) -> int:
	return accumulated_score + _value;
