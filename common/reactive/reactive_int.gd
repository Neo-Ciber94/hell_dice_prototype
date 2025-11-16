class_name ReactiveInt 
extends Reactive;

signal on_value_changed(new_value: int)

@export var value: int = 0:
	set(new_value):
		value = new_value;
		on_value_changed.emit(new_value)

func _init(initial_value: int) -> void:
	value = initial_value;
	on_value_changed.connect(on_changed.emit)

func emit_latest() -> void:
	on_value_changed.emit(value)
