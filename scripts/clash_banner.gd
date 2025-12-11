class_name ClashBanner
extends Node2D

@onready var label: Label = $Label
@onready var anim: AnimationPlayer = $AnimationPlayer

func show_text(text: String):
	label.text = text

	anim.play("slide")
	await anim.animation_finished

	queue_free()
