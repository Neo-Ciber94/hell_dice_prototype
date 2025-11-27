class_name Dice3D
extends RigidBody3D

signal on_stopped()

@onready var dice_value_indicator: Node3D = $DiceValueIndicator
@onready var dice_value_label: Label3D = %DiceValueLabel
@onready var dice_hit_audio_player: AudioStreamPlayer3D = $DiceHitAudioPlayer
@onready var dice_hit_ground_audio_player: AudioStreamPlayer3D = $DiceHitGroundAudioPlayer
@onready var audio_timer: Timer = $AudioTimer

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
	dice_value_indicator.hide()
	body_entered.connect(_on_collision)

func roll_dice() -> void:
	_is_rolling = true;
	dice_value_indicator.hide()

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
		_on_stopped()
		
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
	
func _on_stopped() -> void:
	on_stopped.emit()

	dice_value_indicator.global_position = global_position + Vector3(0, 0.5, 0);
	dice_value_indicator.show()
	dice_value_label.text = str(get_dice_value())
	
func _on_collision(body: Node3D) -> void:
	if body.is_in_group("ground"):
		_play_hit_ground_sfx()
	else:
		_play_hit_sfx()
	
func _play_hit_sfx() -> void:
	if dice_hit_audio_player.playing || not audio_timer.is_stopped():
		return;
		
	_play_audio(dice_hit_audio_player)
	
func _play_hit_ground_sfx() -> void:
	if dice_hit_ground_audio_player.playing || not audio_timer.is_stopped():
		return;
		
	_play_audio(dice_hit_ground_audio_player)
	
func _play_audio(audio_player: AudioStreamPlayer3D) -> void:
	var volume = randf_range(1, 1.5)
	var pitch = randf_range(1, 2.0)
	audio_player.volume_linear = volume;
	audio_player.pitch_scale = pitch
	audio_player.play()
	audio_timer.start(0.5)
	
func is_stopped() -> bool:
	const STOP_THRESHOLD = 0.05;
	return linear_velocity.length() < STOP_THRESHOLD and angular_velocity.length() < STOP_THRESHOLD
