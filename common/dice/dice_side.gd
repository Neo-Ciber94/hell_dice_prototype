class_name DiceSide

var side_value: int;
var side_text: String;

func _init(value: int, text: String) -> void:
	side_value = value;
	side_text = text;


func _to_string() -> String:
	return str({
		side_value = side_value,
		side_text = side_text
	})
