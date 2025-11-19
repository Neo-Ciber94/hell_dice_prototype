class_name RNG extends RandomNumberGenerator

static func with_seed(rng_seed: int) -> RNG:
	var rng = RNG.new()
	rng.seed = rng_seed;
	return rng;

func pick_random(array: Array) -> Variant:
	return array.get(super.randi_range(0, array.size() - 1))

func take_random(array: Array) -> Variant:
	var idx = super.randi_range(0, array.size() - 1);
	var value = array.get(idx)
	array.remove_at(idx)
	return value;

func take_random_array(array: Array, count: int) -> Array:
	var result: Array = []
	
	while result.size() < count and array.size() > 0:
		var item = take_random(array)
		result.push_back(item)
	
	return result;

func rand_bool(probability: float = 0.5) -> bool:
	return super.randf() < probability

func rand_rect_point(rect: Rect2i) -> Vector2i:
	var x = super.randi_range(rect.position.x, rect.position.x + rect.size.x - 1)
	var y = super.randi_range(rect.position.y, rect.position.y + rect.size.y - 1)
	return Vector2i(x, y)

func rand_in_circle(radius: float, center: Vector2 = Vector2.ZERO) -> Vector2:
	var angle = randf() * TAU
	var r = sqrt(randf()) * radius
	var x = cos(angle)
	var y = sin(angle);
	return center + Vector2(x, y) * r

func rand_points_in_circle(radius: float, min_distance: float, points: int, max_iterations: int = 10) -> Array[Vector2]:
	assert(min_distance > 0 && min_distance < radius / 2.0, "Min distance must be greater than 0 and lower than the radious")
	
	var sample_fn = func(point: Vector2): return rand_in_circle(radius, point)
	return _sample_points(sample_fn, min_distance, points, max_iterations)

func rand_in_donut(inner_radius: float, outher_radius: float, center: Vector2 = Vector2.ZERO) -> Vector2:
	var angle = TAU * randf()
	var radius = sqrt(pow(inner_radius, 2) + pow(outher_radius, 2) - pow(inner_radius, 2) * randf())
	var x = radius * cos(angle)
	var y = radius * sin(angle)
	return center + Vector2(x, y)

func rand_points_in_donut(inner_radius: float, outher_radius: float, min_distance: float, points: int, max_iterations: int = 10) -> Array[Vector2]:
	assert(min_distance > 0, "Min distance must be greater than 0")
	
	var sample_fn = func(point: Vector2): return rand_in_donut(inner_radius, outher_radius, point)
	return _sample_points(sample_fn, min_distance, points, max_iterations)

# sample_point: Callable[Vector2]
func _sample_points(sample_point: Callable, min_distance: float, points: int, max_iterations: int = 10) -> Array[Vector2]:
	var results: Array[Vector2] = []
	var last_center: Vector2 = Vector2.ZERO
	
	while max_iterations > 0 && results.size() < points:
		var point = sample_point.call(last_center)
		var is_valid_point = true;
		
		for p in results:
			var distance = point.distance_to(p)
			if distance < min_distance:
				is_valid_point = false;
				break;
			
		if is_valid_point:
			last_center = point;
			results.push_back(point)
		else:
			max_iterations -= 1;

	return results;

func shuffle(array: Array) -> void:
	for from_idx in array.size():
		var to_idx = super.randi_range(0, array.size() - 1)
		var temp = array[from_idx]
		array[from_idx] = array[to_idx]
		array[to_idx] = temp 
