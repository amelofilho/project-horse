class_name SkillsColumn
extends Control

const SKILL_ICONS := [
	preload("res://assets/UI_Visuals/Skills_Icons/guard.png"),
	preload("res://assets/UI_Visuals/Skills_Icons/heavy_melee.png"),
	preload("res://assets/UI_Visuals/Skills_Icons/light_attack.png"),
	preload("res://assets/UI_Visuals/Skills_Icons/light_spell.png"),
	preload("res://assets/UI_Visuals/Skills_Icons/magic_guard.png"),
	preload("res://assets/UI_Visuals/Skills_Icons/melee_buff.png"),
	preload("res://assets/UI_Visuals/Skills_Icons/team_heal.png"),
]

#@onready var root_1 = $SingleCol
#@onready var root_2 = $DoubleCol
@onready var root_3 = $TripleCol

const ROWS_PER_COLUMN := 3

func _ready():
	# hide everything at start
	#root_1.visible = false
	#root_2.visible = false
	root_3.visible = false

# generates appropriate number of columns depending on possible skills...
func generate_skills():
	#root_1.visible = false
	#root_2.visible = false
	root_3.visible = false

	var active_root: Node
	#match power:
		#1: active_root = root_1
		#2: active_root = root_2
		#3: active_root = root_3
		#_: active_root = root_1

	active_root = root_3
	active_root.visible = true

	# Collect all column containers
	var containers: Array = []
	for column in active_root.get_children():
		if column.has_node("SkillsContainer"):
			containers.append(column.get_node("SkillsContainer"))

	# Clear them
	for c in containers:
		for child in c.get_children():
			child.queue_free()

	var icon_size := Vector2(100, 100)
	
	for container in containers:
		container.columns = 1
		container.size_flags_vertical = Control.SIZE_EXPAND_FILL
		container.custom_minimum_size = Vector2(0, 300)

	for container in containers:
		for i in range(ROWS_PER_COLUMN):
			#print("  Adding icon row", i, " to container:", container.get_parent().name)
			var tex: Texture2D = SKILL_ICONS[randi() % SKILL_ICONS.size()]
			var icon := TextureRect.new()
			icon.texture = tex
			icon.custom_minimum_size = icon_size
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			container.add_child(icon)
