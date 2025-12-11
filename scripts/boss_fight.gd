# script manages the cutscene vs boss fight handoff
extends Node2D

@onready var cutscene_manager := $CutsceneManager
@onready var battle_manager := $BossFightManager

func _ready() -> void:
	print("[BossFight] Waiting for cutscene to finish before starting battle...")
	
	battle_manager.set_process(false)
	cutscene_manager.cutscene_finished.connect(_on_cutscene_finished)
	
func _on_cutscene_finished() -> void:
	print("[BossFight] Cutscene finished! Starting battle now.")
	
	battle_manager.start_battle()
	battle_manager.set_process(true)
