class_name BossFightManager
extends Node

const PLAYER_SCENE = preload("res://scenes/entities/player.tscn")
const BOSS_SCENE = preload("res://scenes/entities/boss.tscn")
const MAX_PLAYERS = 2

var players: Array[Entity] = []
var boss: Entity


func _ready() -> void:
	spawn_players()
	spawn_boss()
	start_boss_fight()


func spawn_players() -> void:
	var player_positions = [Vector2(-600, -120), Vector2(-200, -120)]
	
	for i in range(MAX_PLAYERS):
		var player_instance = PLAYER_SCENE.instantiate() as Entity
		player_instance.global_position = player_positions[i]
		player_instance.name = "Player_%d" % (i + 1)
		print(player_instance.name)
		
		add_child(player_instance)
		players.append(player_instance)
			
		#generate skills bar for this player
		var bar = player_instance.get_node_or_null("SkillsBar")
		if bar:
			bar.show_bar()
			
		#generate skills column for this player
		var col = player_instance.get_node_or_null("SkillsColumn")
		if col:
			col.generate_skills()


func spawn_boss() -> void:
	var boss_position = Vector2(400, -120)
	var boss_instance = BOSS_SCENE.instantiate() as Entity
	boss_instance.global_position = boss_position
	boss_instance.name = "Boss"
	
	add_child(boss_instance)
	boss = boss_instance

	var bar: SkillsBar = boss_instance.get_node_or_null("SkillsBar")
	if bar:
		print("Boss bar found. Showing bar.")
		bar.show_bar()
	else:
		push_error("Boss has NO SkillsBar node!")


func start_boss_fight() -> void:
	
	# Transitions to the actual boss fight
	pass
