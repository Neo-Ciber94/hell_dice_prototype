class_name DiceContext;

var dices: Array[DiceData] = []
var score: int = 0;

func _init(rolling_dices: Array[DiceData]) -> void:
	dices = rolling_dices;
