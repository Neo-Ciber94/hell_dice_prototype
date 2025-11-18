class_name BoardVersus
extends Control

const MIN_ROLL_DICES = 1;
const MAX_ROLL_DICES = 6;
const MAX_SIDE_DICES = 7;

@onready var current_dice_container: HFlowContainer = %CurrentDiceContainer
@onready var dice_container: VBoxContainer = %DiceContainer
@onready var roll_dice_button: Button = %RollDiceButton

@export var dice_collection: Array[Dice] = []

func _ready() -> void:
	roll_dice_button.pressed.connect(_on_roll_dices)
	
func _on_roll_dices() -> void:
	pass
