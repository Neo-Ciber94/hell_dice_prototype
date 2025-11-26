class_name Dice3D
extends RigidBody3D

signal on_stopped()

@onready var dice_sides: Array[Marker3D] = [
	$DiceModel/Side_1, 
	$DiceModel/Side_2, 
	$DiceModel/Side_3, 
	$DiceModel/Side_4, 
	$DiceModel/Side_5, 
	$DiceModel/Side_6
]

@export_group("Rolling")
@export_range(0, 1000) var min_roll_force: float = 20.0;
@export_range(0, 1000) var max_roll_force: float = 30.0;
@export_range(0, 1000) var min_roll_torque: float = 8.0;
@export_range(0, 1000) var max_roll_torque: float = 12.0;

var _rng = RNG.new()
var _is_rolling: bool = false;
var _elapsed_till_time: float = 0.0;

func _ready() -> void:
	assert(min_roll_force <= max_roll_force)
	assert(min_roll_torque <= max_roll_torque)

func roll_dice() -> void:
	_is_rolling = true;

	var roll_impulse = Vector3(
		_get_rand_force(_rng) * _rng.rand_sign(),
		_get_rand_force(_rng) * -1,
		_get_rand_force(_rng)  * _rng.rand_sign(),
	)
	
	var roll_torque = Vector3(
		_get_rand_torque(_rng) * _rng.rand_sign(),
		_get_rand_torque(_rng) * _rng.rand_sign(),
		_get_rand_torque(_rng) * _rng.rand_sign(),
	)
	
	apply_impulse(roll_impulse)
	apply_torque_impulse(roll_torque)

func _get_rand_force(rng: RNG) -> float:
	return rng.randf_range(min_roll_force, max_roll_force)
	
func _get_rand_torque(rng: RNG) -> float:
	return rng.randf_range(min_roll_torque, max_roll_torque)

func _physics_process(delta: float) -> void:
	_check_stopped(delta)

func _check_stopped(delta: float) -> void:
	const STILL_TIME = 0.2;

	if not _is_rolling:
		return;
		
	if is_stopped():
		_elapsed_till_time += delta;
	else:
		_elapsed_till_time = 0;
		
	if _elapsed_till_time >= STILL_TIME:
		_elapsed_till_time = 0;
		_is_rolling = false;
		freeze = false
		on_stopped.emit()
		
func get_dice_value() -> int:
	var side = _get_top_side();
	
	if side == null:
		return -1;
		
	var num = side.name.split("Side_")[1]
	return int(num)

func _get_top_side() -> Marker3D:
	var top_side: Marker3D = null
	
	for side in dice_sides:
		if top_side == null:
			top_side = side; 
		elif side.global_position.y > top_side.global_position.y:
			top_side = side;
			
	return top_side;
	
func _find_side(value: int) -> Marker3D:
	for side in dice_sides:
		var num = int(side.name.split("Side_")[1])
		if num == value:
			return side;
			
	return null;
	
func _is_colliding() -> bool:
	for contact in get_contact_count():
		if linear_velocity.length() > 2.0:
			return true;
			
	return false;
	
func is_stopped() -> bool:
	const STOP_THRESHOLD = 0.05;
	return linear_velocity.length() < STOP_THRESHOLD and angular_velocity.length() < STOP_THRESHOLD
