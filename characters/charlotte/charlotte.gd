class_name CharlotteDemon
extends Node2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	animation_player.play("idle")
	
func start_turn() -> void:
	sprite_2d.flip_h = true;
	
func end_turn() -> void:
	sprite_2d.flip_h = false;

func damaged() -> void:
	animation_player.play("damaged")
	
	if animation_player.is_playing():
		await animation_player.animation_finished
		
	animation_player.play("idle")
