extends Node

var current_scene: Node


func _ready():
	load_scene("res://scenes/title_screen.tscn")


func load_scene(scene_path: String):
	
	# Frees the old	scene when switching
	if current_scene:
		current_scene.queue_free()

	# Loads the new scene as a child of World
	var new_scene = load(scene_path).instantiate()
	add_child(new_scene)
	current_scene = new_scene
