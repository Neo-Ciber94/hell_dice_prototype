@tool
class_name HueRotatedTexture
extends Texture2D

var _cached_texture: ImageTexture

@export_range(-360, 360) var hue_rotation_degrees: float = 0.0:
	set(value):
		hue_rotation_degrees = value
		changed.emit()
		_update_texture()

@export_range(0, 10) var saturation: float = 1.0:
	set(value):
		saturation = value;
		changed.emit()
		_update_texture()
		
@export_range(0, 1) var contrast: float = 0.0:
	set(value):
		contrast = value;
		changed.emit()
		_update_texture()
		
@export var invert: bool = false:
	set(value):
		invert = value;
		changed.emit()
		_update_texture()
		
@export var source: Texture2D:
	set(value):
		source = value
		emit_changed()
		_update_texture()

@export_group("Actions")
@export_tool_button("Update Texture", "Callable") var update_texture = _update_texture 

@export_group("Preview")
@export var preview_image: ImageTexture:
	get: return _cached_texture
	set(_value): pass


func _update_texture() -> void:
	if source == null:
		_cached_texture = null
		return

	var image = _recolor_image(source.get_image())
	_cached_texture = ImageTexture.create_from_image(image)


func _recolor_image(image: Image) -> Image:
	var result = image.duplicate()

	var hue_shift = deg_to_rad(hue_rotation_degrees)
	var w = result.get_width()
	var h = result.get_height()

	for x in range(w):
		for y in range(h):
			var color = result.get_pixel(x, y)
			if color.a == 0.0:
				continue

			var hsv = _rgb_to_hsv(color)
			hsv.x = fmod(hsv.x + hue_shift / (PI * 2.0), 1.0)
			if hsv.x < 0.0:
				hsv.x += 1.0
			var new_color = _hsv_to_rgb(hsv, color.a)
			new_color = new_color.darkened(contrast)
			
			if invert:
				new_color = new_color.inverted()
			
			new_color = saturate_color(new_color, saturation)
			
			result.set_pixel(x, y, new_color)

	return result

func saturate_color(color: Color, amount: float) -> Color:
	# amount: 1.0 = unchanged, 0.0 = grayscale, >1.0 = more saturated
	var hsv = _rgb_to_hsv(color)
	hsv.y = clamp(hsv.y * amount, 0.0, 1.0)
	return _hsv_to_rgb(hsv, color.a)

func _rgb_to_hsv(c: Color) -> Vector3:
	var maxv = max(c.r, c.g, c.b)
	var minv = min(c.r, c.g, c.b)
	var delta = maxv - minv

	var h: float
	if delta == 0.0:
		h = 0.0
	elif maxv == c.r:
		h = fmod((c.g - c.b) / delta, 6.0)
	elif maxv == c.g:
		h = ((c.b - c.r) / delta) + 2.0
	else:
		h = ((c.r - c.g) / delta) + 4.0
	h /= 6.0

	var s = 0.0 if maxv == 0.0 else delta / maxv
	var v = maxv
	return Vector3(h, s, v)


func _hsv_to_rgb(hsv: Vector3, alpha: float) -> Color:
	var h = hsv.x * 6.0
	var s = hsv.y
	var v = hsv.z
	var i = int(floor(h)) % 6
	var f = h - floor(h)
	var p = v * (1.0 - s)
	var q = v * (1.0 - f * s)
	var t = v * (1.0 - (1.0 - f) * s)

	var r: float
	var g: float
	var b: float
	match i:
		0: r = v; g = t; b = p
		1: r = q; g = v; b = p
		2: r = p; g = v; b = t
		3: r = p; g = q; b = v
		4: r = t; g = p; b = v
		_: r = v; g = p; b = q

	return Color(r, g, b, alpha)


func _draw(to_canvas_item: RID, pos: Vector2, modulate: Color, transpose: bool) -> void:
	if _cached_texture:
		_cached_texture.draw(to_canvas_item, pos, modulate, transpose)

func _draw_rect(to_canvas_item: RID, rect: Rect2, tile: bool, modulate: Color, transpose: bool) -> void:
	if _cached_texture:
		_cached_texture.draw_rect(to_canvas_item, rect, tile, modulate, transpose)

func _draw_rect_region(to_canvas_item: RID, rect: Rect2, src_rect: Rect2, modulate: Color, transpose: bool, clip_uv: bool) -> void:
	if _cached_texture:
		_cached_texture.draw_rect_region(to_canvas_item, rect, src_rect, modulate, transpose, clip_uv)

func _get_width() -> int:
	return _cached_texture.get_width() if _cached_texture else 0

func _get_height() -> int:
	return _cached_texture.get_height() if _cached_texture else 0

func _has_alpha() -> bool:
	return _cached_texture.has_alpha() if _cached_texture else false

func _is_pixel_opaque(x: int, y: int) -> bool:
	return _cached_texture.is_pixel_opaque(x, y) if _cached_texture else false
