class_name BossSkillsBar
extends Control

@export var y_offset := -130
@onready var bar_3: Control = $TripleSkills
# The node that will HOLD all arrow instances
@onready var boss_preview_arrows : Node = $BossPreviewArrows

# Preload arrow scene
const ARROW_SCENE := preload("res://scenes/UI/boss_preview_arrows.tscn")

# References that BattleManager or ActionHandler MUST inject
var players : Array = []
var boss : Node = null

func _ready():
	# position skill boxes y above player
	position.y = y_offset

# Call this from Player.gd
func show_bar():
	bar_3.visible = true
	
func show_preview_arrows():
	for arrow in boss_preview_arrows.get_children():
		arrow.visible = true

func hide_preview_arrows():
	for arrow in boss_preview_arrows.get_children():
		arrow.visible = false

func setup(players_array: Array, boss_ref: Node) -> void:
	# Called by BattleManager or ActionHandler after spawning characters
	players = players_array
	boss = boss_ref
	print("[BossSkillsBar] setup(): players + boss assigned.")
