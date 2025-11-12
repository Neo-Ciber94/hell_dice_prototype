@tool
@abstract
class_name DiceBehaviour
extends Resource

enum Order {
	FIRST = 1,
	LAST = 999
}

@export_group("General")
@export var dice_name: String;
@export var dice_texture: Texture2D;

@abstract
func get_dice_sides() -> Array[DiceSide];

@abstract
func roll_dice(rng: RNG) -> void;

@abstract
func get_dice_value() -> int;

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
