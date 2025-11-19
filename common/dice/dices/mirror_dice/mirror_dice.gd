@tool
class_name MirrorDice
extends Dice

@export var sides: int = 6;
var _value: int = 0;
var _has_value: bool = false;

func on_roll_finished(ctx: BoardContext) -> void:
	for dice in ctx.dices:
		_value = max(dice.get_dice_value(), _value) 

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

func calculate_dice_score(_ctx: BoardContext, accumulated_score: int) -> int:
	return accumulated_score + _value;

func get_dice_value() -> int:
	return _value;

func get_dice_order() -> Order:
	return Order.EARLY
