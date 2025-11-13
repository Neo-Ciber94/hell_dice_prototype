class_name DiceSelectionScreen
extends ColorRect

const MAX_SELECTABLES = 3;

signal on_selection_done(values: Array[Dice])

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
	var tween = create_tween();
	self.modulate.a = 0.0;
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "modulate:a", 1.0, 0.5).from(0);
	tween.tween_property(self, "scale", Vector2.ONE, 0.5).from(Vector2.ONE * 0.8)
	
	show.call_deferred()
	_prepare_current_dices(board)
	_prepare_dice_selection()
		
func _on_dice_selected(_selected: DiceUI) -> void:
	for child in dice_selection_card_container.get_children():
		if child is DiceSelectionCard:
			child.disabled = true;
		
func _prepare_dice_selection() -> void:
	var DICE_SELECTION_CARD = load("uid://c1jx6x1hs7f51")
	
	for child in dice_selection_card_container.get_children():
		child.queue_free()
		
	for dice in _get_available_dices():
		var selection_card = DICE_SELECTION_CARD.instantiate() as DiceSelectionCard;
		selection_card.dice = dice;
		dice_selection_card_container.add_child(selection_card)
		
func _prepare_current_dices(board: Board) -> void:
	for child in current_dice_container.get_children():
		child.queue_free()
		
	var dices = board.dices_ui.map(func(d: DiceUI): return d.dice)
	var DICE = load("uid://ynjdjcukvk4c")
	
	for d: Dice in dices:
		var dice_ui = DICE.instantiate() as DiceUI;
		dice_ui.dice = d;
		current_dice_container.add_child(dice_ui)
		
func _get_available_dices() -> Array[Dice]:
	const DICES_PATH = "res://common/dice/dices/"
	var result: Array[Dice] = []
	var files = FileUtils.read_files(DICES_PATH, "*.tres", true)
	
	for file in files:
		var coin = load(file) as Dice;
		if coin and coin.is_selectable:
			result.push_back(coin)
	
	print("%s available dices found" % result.size())
	result.shuffle()
	return result.slice(0, MAX_SELECTABLES)

func _on_skip_button() -> void:
	_notify_changed()
	hide()
	
func _on_cancel_button() -> void:
	_notify_changed()
	hide()

func _notify_changed() -> void:
	on_selection_done.emit(_get_selection())

func _get_selection() -> Array[Dice]:
	var result: Array[Dice] = []
	
	for d in current_dice_container.get_children():
		if d is DiceUI:
			result.push_back(d.dice.duplicate())
	
	return result;
