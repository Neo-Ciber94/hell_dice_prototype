class_name DicePickerScreen
extends Control

signal on_selected(dice: Dice)

@onready var cards_container: HBoxContainer = %CardsContainer
@onready var continue_button: Button = %ContinueButton
@onready var cancel_button: Button = %CancelButton

var _selected_dice: Dice;

func _ready() -> void:
	continue_button.pressed.connect(_on_continue_pressed)
	cancel_button.pressed.connect(_on_cancel_pressed)
	
func open_dice_picker() -> void:
	const DICE_SELECTION_CARD = preload("uid://c1jx6x1hs7f51")
	var dices_available = _get_available_dices()
	
	for child in cards_container.get_children():
		child.queue_free()
	
	for dice in dices_available:
		var dice_card = DICE_SELECTION_CARD.instantiate() as DiceSelectionCard;
		dice_card.dice = dice;
		cards_container.add_child(dice_card)
		
	show()

func _on_continue_pressed() -> void:
	if _selected_dice:
		on_selected.emit(_selected_dice)
		_close()
	
func _on_cancel_pressed() -> void:
	_close()

func _close() -> void:
	_selected_dice = null;
	hide()

func _get_available_dices() -> Array[Dice]:
	const DICES_PATH = "res://common/dice/dices/"
	const MAX_SELECTABLES = 3;
	
	var result: Array[Dice] = []
	var files = FileUtils.read_files(DICES_PATH, "*.tres", true)
	
	for file in files:
		var coin = load(file) as Dice;
		if coin and coin.is_selectable:
			result.push_back(coin)
	
	print("%s available dices found" % result.size())
	result.shuffle()
	return result.slice(0, MAX_SELECTABLES)
