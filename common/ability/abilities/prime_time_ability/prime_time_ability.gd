class_name PrimeTimeAbility
extends AbilityData

static var PRIME_CACHE: Dictionary[int, bool] = {}

var _value: int = 0;

func on_roll_start(_board: Board) -> void:
	_value = 0;
	
func on_roll_finished(board: Board) -> void:
	var total = board.get_total_dice_score()
	
	if is_prime(total):
		_value = _get_next_prime(total)
	else:
		print("%s is not prime" % total)
		
func on_calculating_score(_board: Board) -> void:
	await MessageManager.instance.show_message("Prime Time: +%s" % _value)
		
func calculate_score(_board: Board, accumulated_score: int) -> int:
	return accumulated_score + _value;

static func _get_next_prime(cur: int) -> int:
	if cur % 2 == 0:
		cur += 1;
	
	while cur > 0:
		cur += 2;
		
		if is_prime(cur):
			return cur;
			
	return 0;

static func is_prime(value: int) -> bool:
	const CACHE_THREDSHOLD = 1000_000
	
	if value < CACHE_THREDSHOLD:
		return _check_is_prime(value)
	
	if PRIME_CACHE.has(value):
		return PRIME_CACHE.get(value)
		
	var result = _check_is_prime(value);
	PRIME_CACHE.set(value, result)
	return result;

static func _check_is_prime(value: int) -> bool:
	if value <= 1:
		return false;
		
	if value == 2:
		return true;
		
	if value % 2 == 0:
		return false;
		
	var i = 3;
	
	while i < value:
		if value % i == 0:
			return false;
			
		i += 2;
	
	return true;
