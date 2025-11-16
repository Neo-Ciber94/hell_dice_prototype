class_name PhysicsDice
extends RigidBody2D

@export var force_amount: float = 1000.0;
@export_range(-360, 360, 1.0, "radians_as_degrees") var torque_amount: float = deg_to_rad(100.0);

var _is_hovered: bool = false;

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered() -> void:
	_is_hovered = true;
	
func _on_mouse_exited() -> void:
	_is_hovered = false;

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_released() and _is_hovered:
		var mouse_event = event as InputEventMouseButton;
		if mouse_event.button_index == MouseButton.MOUSE_BUTTON_RIGHT:
			random_roll()

func roll_dice(dir: Vector2) -> void:
	dir = dir.normalized() * force_amount
	var torque = randf_range(-1, 1) * torque_amount
	
	apply_impulse(dir)
	apply_torque(torque)

func random_roll()-> void:
	var dir = Vector2(
		randf_range(-1, 1),
		randf_range(-1, 1)
	) * force_amount;
	
	var torque = randf_range(-1, 1) * torque_amount
	
	apply_impulse(dir)
	apply_torque(torque)
