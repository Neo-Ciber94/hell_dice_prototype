@tool
class_name StyleBoxStacked
extends StyleBox

@export var style_boxes: Array[StyleBox]:
	set(value):
		style_boxes = value;
		changed.emit()
		
		for style_box in value:
			if style_box and not style_box.changed.is_connected(changed.emit):
				style_box.changed.connect(changed.emit)
		
func _draw(to_canvas_item: RID, rect: Rect2) -> void:
	for style_box in style_boxes:
		if style_box:
			style_box.draw(to_canvas_item, rect)
