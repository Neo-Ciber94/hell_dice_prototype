class_name BoardData

const MAX_DICES: int = 6;

signal on_target_score_changed(new_value: int)
signal on_current_score_changed(new_value: int)
signal on_current_round_changed(new_round: int)
signal on_dices_changed(new_dices: Array[Dice])

var target_score: int;
var current_score: int;
var current_round: int;

var dices: Array[Dice] = []:
	get: return dices.slice(0, MAX_DICES)
	set(value):
		dices = value.slice(0, MAX_DICES)
		on_dices_changed.emit(dices)
	
