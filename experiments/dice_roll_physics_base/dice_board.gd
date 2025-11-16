class_name DiceBoard
extends Control

const PHYSICS_DICE = preload("uid://dutrixl5ljwbw")

@onready var spawn_point: Marker2D = $SpawnPoint
@onready var roll_anchor: Marker2D = $RollAnchor

@export var dice_count: int = 6;

var _dices: Array[PhysicsDice] = []

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_released() and event.keycode == KEY_SPACE:
		_roll_dices()
		
func _roll_dices() -> void:
	for dice in _dices:
		dice.queue_free()
		
	_dices.clear()
	
	for _idx in dice_count:
		var dice = PHYSICS_DICE.instantiate() as PhysicsDice;
		add_child(dice)
		_dices.push_back(dice)
		
		dice.global_position = spawn_point.global_position
		
		var dir = spawn_point.global_position.direction_to(roll_anchor.global_position)
		var target_dir = dir.rotated(randf_range(-1, 1) * deg_to_rad(15))
		
		dice.roll_dice(target_dir)
