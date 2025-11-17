class_name DiceDraggable
extends Control

@onready var dice_ui: DiceUI = $".."

func _get_drag_data(_at_position: Vector2) -> Variant:
	if dice_ui.parent_card && dice_ui.parent_card.disabled:
		return null;
	
	const DICE_PREVIEW = preload("uid://dpgm01o6sb5x3")

	if dice_ui.dice and dice_ui.dice.dice_texture:
		var preview := Control.new()
		var dice_preview := DICE_PREVIEW.instantiate() as DicePreview;
		dice_preview.dice = dice_ui.dice;
		dice_preview.position = -dice_preview.custom_minimum_size / 2.0
		preview.add_child(dice_preview)
		set_drag_preview(preview)

	return self.dice_ui

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	var other_dice = data as DiceUI;
	
	if other_dice == null || other_dice == self.dice_ui:
		return false;
		
	if other_dice.parent_card and dice_ui.parent_card:
		return false;
		
	if (dice_ui.parent_card and dice_ui.parent_card.disabled) || (other_dice.parent_card and other_dice.parent_card.disabled):
		return false;
		
	return true;

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var other = data as DiceUI;
	
	if other == null:
		return;
		
	var other_dice: Dice = other.dice as Dice;
	var temp: Dice = dice_ui.dice as Dice;
	dice_ui.dice = other_dice
	other.dice = temp 
	self.dice_ui._prepare()
	other._prepare()
	
	if dice_ui.parent_card:
		dice_ui.parent_card.dice = other_dice;
		dice_ui.parent_card.on_dice_changed.emit()
		
	if other.parent_card:
		other.parent_card.dice = other.dice;
		other.parent_card.on_dice_changed.emit()
		
	if other.parent_card:
		EventBus.on_dice_selected.emit(self.dice_ui)
