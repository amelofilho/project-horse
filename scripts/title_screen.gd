extends Node2D

@export var menu_music: AudioStream
@onready var player := $MusicPlayer

func _ready() -> void:
	if menu_music:
		player.stream = menu_music
		player.play()
		#player.loop = true
