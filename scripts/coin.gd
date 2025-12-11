class_name Coin
extends Node2D

@onready var anim: AnimationPlayer = $AnimationPlayer

var should_break:bool = false

func _ready() -> void:
	anim.play("RESET")

func break_coin():
	anim.play("shatter")
	await anim.animation_finished
	
func spin(heads:bool):
	anim.play("flip")
	await anim.animation_finished
	if heads:
		anim.play("turn_heads")
	else:
		anim.play("turn_tails")
	await anim.animation_finished
	
func done():
	if should_break:
		await break_coin()
	else:
		await get_tree().create_timer(0.6).timeout
	queue_free()
	
func play_land():
	$PlayHeads.play()
	
func play_shatter():
	$Shatter.play()
