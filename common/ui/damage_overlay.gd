class_name DamageOverlay
extends CanvasLayer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func damaged() -> void:
	animation_player.play("damaged")
	
	if animation_player.is_playing():
		await animation_player.animation_finished
