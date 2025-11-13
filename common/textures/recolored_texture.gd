@tool
class_name ReColoredTexture 
extends Texture2D

var _cached_texture: ImageTexture

@export var color_replacement_map: Dictionary[Color, Color] = {}
@export var source: Texture2D:
	set(value):
		source = value;
		emit_changed()
		_update_texture()

@export_group("Actions")
@export_tool_button("Update Texture", "Callable") var update_texture = _update_texture 
@export_tool_button("Generate Replacement Map", "Callable") var generate_color_replacement_map = _generate_color_replacement_map

@export_group("Preview")
@export var preview_image: ImageTexture:
	get: return _cached_texture;
	set(_value):
		pass
		
func _generate_color_replacement_map():
	assert(_cached_texture, "No texture have been loaded")
	
	var image = source.get_image();
	color_replacement_map = {}

	for x in image.get_width():
		for y in image.get_height():
			var color = image.get_pixel(x, y)
			
			if color == Color.TRANSPARENT:
				continue;
			
			if not color_replacement_map.has(color):
				color_replacement_map.set(color, color)

func _update_texture() -> void:
	if source == null:
		_cached_texture = null
		return;
		
	var image = _recolor_image(source.get_image())
	_cached_texture = ImageTexture.create_from_image(image)
	
func _recolor_image(image: Image) -> Image:
	if color_replacement_map.is_empty():
		return image;
	
	for x in image.get_width():
		for y in image.get_height():
			var color = image.get_pixel(x, y)
			var replacement_color = color_replacement_map.get(color)
			
			if replacement_color is Color:
				image.set_pixel(x, y, replacement_color)
		
	return image;

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
	if _cached_texture:
		return _cached_texture.get_width()
	return 0

func _get_height() -> int:
	if _cached_texture:
		return _cached_texture.get_height()
	return 0

func _has_alpha() -> bool:
	if _cached_texture:
		return _cached_texture.has_alpha()
	return false

func _is_pixel_opaque(x: int, y: int) -> bool:
	if _cached_texture:
		return _cached_texture.is_pixel_opaque(x, y)
	return false
