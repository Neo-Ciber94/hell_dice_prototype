@abstract
class_name DiceData
extends Resource

enum Order {
	FIRST = 1,
	EARLY = 2,
	LATE = 3,
	LAST = 999
}

@export_group("General")
@export var dice_name: String;

@export_group("Texture")
@export var dice_texture: AtlasTexture;
@export var dice_texture_size: Vector2 = Vector2(16, 16)
@export var dice_texture_region: Vector2 = Vector2(2, 3)

@abstract
func get_dice_sides() -> Array[DiceSide];

@abstract
func get_selected_dice_side() -> DiceSide;

@abstract
func set_selected_dice_side(side: DiceSide) -> void;

@abstract
func calculate_score(ctx: DiceContext) -> void;

func get_dice_sides_as_map() -> Dictionary[int, DiceSide]:
	var result: Dictionary[int, DiceSide] = {}
	
	for side in get_dice_sides():
		result.set(side.side_value, side)
	
	return result;

func get_selected_dice_value() -> int:
	var selected_dice = get_selected_dice_side();
	
	if selected_dice:
		return selected_dice.side_value;
		
	return 0;
	
func on_roll_finished(ctx: DiceContext) -> void:
	pass 

func get_order() -> Order:
	return Order.FIRST;

func instantiate_dice() -> Dice3D:
	const DICE_3D = preload("uid://cgqdnpid55n28")
	var dice_instance = DICE_3D.instantiate() as Dice3D;
	dice_instance.dice_data = self;
	return dice_instance;

func get_dice_side_texture(side_index: int) -> Texture2D:
	assert(side_index > 0)
	var dice_texture_offset_map = _get_texture_atlas_offset_map()
	var atlas_region = dice_texture_offset_map.get(side_index)
	
	var texture = dice_texture.duplicate() as AtlasTexture;
	texture.region = Rect2(atlas_region, dice_texture_size)
	return texture;
	
func _get_texture_atlas_offset_map() -> Dictionary[int, Vector2]:
	var result: Dictionary[int, Vector2] = {}
	
	for x in dice_texture_region.x:
		for y in dice_texture_region.y:
			var atlas_offset = Vector2(x, y) * dice_texture_size;
			result.set(result.size() + 1, atlas_offset)
	
	return result;
