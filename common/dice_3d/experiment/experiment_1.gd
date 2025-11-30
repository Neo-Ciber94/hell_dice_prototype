extends Node3D

@onready var dices: Array[Dice3D] = [
	%Board/Dice3D_1, 
	%Board/Dice3D_2, 
	%Board/Dice3D_3, 
	%Board/Dice3D_6, 
	%Board/Dice3D_4, 
	%Board/Dice3D_5
]
@onready var roll_button: Button = %RollButton
@onready var game_server_2: GameServer2 = $GameServer2

func _ready() -> void:
	roll_button.pressed.connect(_on_roll_button)
	for dice in dices:
		dice.on_stopped.connect(_on_stopped.bind(dice))

func _on_roll_button() -> void:
	_roll_dices()
	
func _roll_dices() -> void:
	for dice in dices:
		dice.roll_dice()

func _on_stopped(dice: Dice3D) -> void:
	var selected = dice.dice_data.get_dice_sides_as_map().get(dice.get_dice_value())
	dice.dice_data.set_selected_dice_side(selected)
	print("Dice %s value: %s" % [dice.name, dice.get_dice_value()])
