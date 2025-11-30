extends Node3D


@onready var dices: Array[Dice3D] = [
	$Board/Dice3D_1, 
	$Board/Dice3D_2, 
	$Board/Dice3D_3, 
	$Board/Dice3D_6, 
	$Board/Dice3D_4, 
	$Board/Dice3D_5
]

func _ready() -> void:
	for dice in dices:
		dice.on_stopped.connect(_on_stopped.bind(dice))

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_released():
		if event.keycode == KEY_SPACE:
			for dice in dices:
				dice.roll_dice()

func _on_stopped(dice: Dice3D) -> void:
	print("Dice %s value: %s" % [dice.name, dice.get_dice_value()])
