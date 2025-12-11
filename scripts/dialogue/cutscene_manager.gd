class_name CutsceneManager
extends Node

signal cutscene_finished

@export var cutscene_music: AudioStream
@onready var music_player := $MusicPlayer

var cutscene_scene: PackedScene = preload("res://scenes/dialogue/cutscene_dialogue.tscn")
var instance: Node = null
var canvas_layer: CanvasLayer = null


func _ready() -> void:
	# check if music loaded...
	print("[CutsceneManager] Ready. cutscene_music =", cutscene_music)
	DialogueManager.got_dialogue.connect(_on_dialogue)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

	# play a cutscene to test
	play_cutscene('res://scenes/resources/intro_cutscene.dialogue')


func play_cutscene(path: String, key: String = "start") -> void:
	_end_cutscene() # clean previous

	# play music if assigned
	if cutscene_music:
		music_player.stream = cutscene_music
		music_player.play()

	var res = load(path) as DialogueResource
	instance = cutscene_scene.instantiate()
	canvas_layer = CanvasLayer.new()
	add_child(canvas_layer)
	canvas_layer.add_child(instance)
	DialogueManager.show_dialogue_balloon(res, key)


func _on_dialogue(line: DialogueManager.DialogueLine) -> void:
	if instance and instance.has_method("set_focus"):
		if line.character.contains("Red"):
			instance.set_focus("red")
		if line.character.contains("Gold"):
			instance.set_focus("yellow")


func _on_dialogue_ended(_resource: DialogueResource) -> void:
	_end_cutscene()
	emit_signal("cutscene_finished")
	print("[CutsceneManager] Cutscene finished signal emitted.")


func _end_cutscene() -> void:
	if music_player:
		music_player.stop()

	if instance:
		instance.queue_free()
		instance = null
