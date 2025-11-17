class_name BoardData
extends Resource

const MAX_DICES: int = 6;

signal on_target_score_changed(new_value: int)
signal on_current_score_changed(new_value: int)
signal on_current_round_changed(new_round: int)
signal on_roll_left_changed(new_value: int)
signal on_dices_changed(new_dices: Array[Dice])

var target_score: int:
	set(value):
		if target_score == value:
			return
			
		target_score = value
		on_target_score_changed.emit(value)

var current_score: int:
	set(value):
		if current_score == value:
			return
			
		current_score = value
		on_current_score_changed.emit(value)

var current_round: int:
	set(value):
		if current_round == value:
			return
			
		current_round = value
		on_current_round_changed.emit(value)

var rolls_left: int:
	set(value):
		if rolls_left == value:
			return;
			
		rolls_left = value;
		on_roll_left_changed.emit(value)

var dices: Array[Dice] = []:
	get: return dices.slice(0, MAX_DICES)
	set(value):
		dices = value.slice(0, MAX_DICES)
		on_dices_changed.emit(dices)
	
class Builder:
	var inner: BoardData

	func _init(initial_dices: Array[Dice]):
		inner = BoardData.new(initial_dices)

	func set_current_score(value: int) -> Builder:
		inner.current_score = value
		return self

	func set_target_score(value: int) -> Builder:
		inner.target_score = value
		return self

	func set_current_round(value: int) -> Builder:
		inner.current_round = value
		return self

	func set_rolls_left(value: int) -> Builder:
		inner.rolls_left = value;
		return self;

	func build() -> BoardData:
		return inner
		
func _init(
	initial_dices: Array[Dice]
) -> void:
	dices = initial_dices
