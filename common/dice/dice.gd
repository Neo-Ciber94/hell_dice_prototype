@tool
@abstract
class_name Dice

extends Resource

enum Order {
	FIRST = 1,
	EARLY = 2,
	#MID = 5,
	LATE = 9,
	LAST = 10
}

@export_group("General")
@export var dice_name: String;
@export_multiline var dice_description: String;
@export var dice_texture: Texture2D;
@export var dice_text_color: Color = Color.from_string("#860223", Color.DARK_RED)
@export var dice_outline_size: int = 0;
@export var dice_outline_color: Color = Color.BLACK

@export_group("Selectable")
@export var is_selectable: bool = true;

func on_roll_start(ctx: BoardContext) -> void:
	pass

func on_roll_finished(ctx: BoardContext) -> void:
	pass

@abstract
func get_dice_sides() -> Array[DiceSide];

@abstract
func roll_dice(rng: RNG) -> void;

@abstract
func get_dice_value() -> int;

@abstract
func calculate_dice_score(ctx: BoardContext, accumulated_score: int) -> int;
	
func get_dice_order() -> Order:
	return Order.FIRST;

func get_selected_dice_side() -> DiceSide:
	var value = get_dice_value();
	
	for side in get_dice_sides():
		if side.side_value == value:
			return side;
			
	return null;

func get_dice_sides_with_selected_as_last() -> Array[DiceSide]:
	var sides = get_dice_sides().duplicate()
	var value = get_dice_value();
	
	for idx in sides.size():
		var side = sides.get(idx) as DiceSide;
		
		if side.side_value == value:
			_swap(sides, idx, sides.size() - 1);
			break;
	
	return sides;
	
func _swap(array: Array, from_idx: int, to_index: int) -> void:
	var temp = array.get(from_idx)
	array[from_idx] = array[to_index]
	array[to_index] = temp;

func _to_string() -> String:
	return str({
		dice_name = dice_name,
		dice_text_color = dice_text_color
	})
