@tool
class_name BankDice
extends Dice

var _value: int = 0;

func on_roll_start(_ctx: BoardContext) -> void:
	_value = 0;

func on_roll_finished(ctx: BoardContext) -> void:
	_value = 0;
	
	for dice in ctx.dices:
		if dice != self:
			_value += dice.get_dice_value()
		
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

func calculate_dice_score(_ctx: BoardContext, accumulated_score: int) -> int:
	return accumulated_score + _value;
