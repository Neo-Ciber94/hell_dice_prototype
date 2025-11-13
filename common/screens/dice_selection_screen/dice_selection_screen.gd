class_name DiceSelectionScreen
extends ColorRect

signal on_selection_done(values: Array[DiceBehaviour])

@onready var dice_selection_card_container: HBoxContainer = %DiceSelectionCardContainer
@onready var replace_dice_outer_container: VBoxContainer = %ReplaceDiceOuterContainer
@onready var current_dice_container: HBoxContainer = %CurrentDiceContainer

@onready var skip_button: Button = %SkipButton
@onready var cancel_button: Button = %CancelButton

func _ready() -> void:
	hide()
	skip_button.pressed.connect(_on_skip_button)
	cancel_button.pressed.connect(_on_cancel_button)
	EventBus.on_dice_selected.connect(_on_dice_selected)
	
func show_dice_selection(board: Board) -> void:
	show()
	_prepare_current_dices(board)
	_prepare_dice_selection()
		
func _on_dice_selected(_selected: Dice) -> void:
	for child in dice_selection_card_container.get_children():
		if child is DiceSelectionCard:
			child.disabled = true;
		
func _prepare_dice_selection() -> void:
	var DICE_SELECTION_CARD = load("uid://c1jx6x1hs7f51")
	
	for child in dice_selection_card_container.get_children():
		child.queue_free()
		
	for dice_behaviour in _get_available_dices():
		var selection_card = DICE_SELECTION_CARD.instantiate() as DiceSelectionCard;
		selection_card.behaviour = dice_behaviour;
		dice_selection_card_container.add_child(selection_card)
		
func _prepare_current_dices(board: Board) -> void:
	for child in current_dice_container.get_children():
		child.queue_free()
		
	var dice_behaviours = board.dices.map(func(d: Dice): return d.behaviour)
	var DICE = load("uid://ynjdjcukvk4c")
	
	for d: DiceBehaviour in dice_behaviours:
		var dice = DICE.instantiate() as Dice;
		dice.behaviour = d;
		current_dice_container.add_child(dice)
		
func _get_available_dices() -> Array[DiceBehaviour]:
	const GOLDEN_DICE = preload("uid://67igom24nxvx")
	
	return [
		GOLDEN_DICE,
		GOLDEN_DICE,
		GOLDEN_DICE
	]

func _on_skip_button() -> void:
	_notify_changed()
	hide()
	
func _on_cancel_button() -> void:
	_notify_changed()
	hide()

func _notify_changed() -> void:
	on_selection_done.emit(_get_selection())

func _get_selection() -> Array[DiceBehaviour]:
	var result: Array[DiceBehaviour] = []
	
	for d in current_dice_container.get_children():
		if d is Dice:
			result.push_back(d.behaviour)
	
	return result;
