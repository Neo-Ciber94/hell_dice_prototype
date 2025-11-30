class_name GameClient2
extends Node

signal on_damaged()
signal on_dead()

@export var max_health: int = 20;
@export var cur_health: int = 0;

func _ready() -> void:
	cur_health = max_health;

func take_damage(amount: int) -> void:
	assert(amount >= 0)
	
	cur_health = max(0, cur_health - amount);
	on_damaged.emit()
	
	if cur_health <= 0:
		on_dead.emit()
	
func is_dead() -> bool:
	return cur_health <= 0;
