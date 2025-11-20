class_name DiceContainer
extends Control

signal on_changed(dices: Array[Dice])

const DICE_ACTIVE = preload("uid://cubcnaqlrqeva")

@export var next_container: DiceContainer;
@export var max_dices: int = 5;

func _ready() -> void:
	assert(next_container)
	assert(next_container != self)
	_clear()

func set_dices(dices: Array[Dice]) -> void:
	_clear()
	for dice in dices:
		add_dice(dice)
	
func add_dice(dice: Dice) -> void:
	if is_full():
		return;
		
	var dice_active = DICE_ACTIVE.instantiate() as DiceActive;
	dice_active.dice = dice;
	dice_active.on_selected.connect(_on_dice_selected)
	add_child(dice_active)
	on_changed.emit(get_dices())
	
func _clear() -> void:
	for child in get_children():
		child.queue_free()
	
func _on_dice_selected(source: DiceActive) -> void:
	if next_container.is_full():
		return;
		
	next_container.add_dice(source.dice)
	source.queue_free()
	on_changed.emit(get_dices())

func take_all_dices() -> Array[Dice]:
	var result: Array[Dice] = get_dices()
	_clear()
	return result;

func get_dices() -> Array[Dice]:
	var result = get_children()\
		.filter(func(x: Node): return x is DiceActive and is_instance_valid(x) and !x.is_queued_for_deletion())\
		.map(func(x: DiceActive): return x.dice)
		
	var temp: Array[Dice] = []
	temp.append_array(result)
	return temp;

func is_full() -> bool:
	return get_dices().size() >= max_dices;
