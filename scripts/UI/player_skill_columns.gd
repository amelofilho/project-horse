class_name SkillsColumn
extends Control

const SKILL_ICONS : Array[Texture2D] = [
	preload("res://assets/UI_Visuals/Skills_Icons/guard.png"),
	preload("res://assets/UI_Visuals/Skills_Icons/heavy_melee.png"),
	preload("res://assets/UI_Visuals/Skills_Icons/light_attack.png"),
	preload("res://assets/UI_Visuals/Skills_Icons/light_spell.png"),
	preload("res://assets/UI_Visuals/Skills_Icons/magic_guard.png"),
	preload("res://assets/UI_Visuals/Skills_Icons/melee_buff.png"),
	preload("res://assets/UI_Visuals/Skills_Icons/team_heal.png"),
]

@onready var col1: GridContainer = $LayoutAnchorFixer/TripleCol/Column1/SkillsContainer
@onready var col2: GridContainer = $LayoutAnchorFixer/TripleCol/Column2/SkillsContainer
@onready var col3: GridContainer = $LayoutAnchorFixer/TripleCol/Column3/SkillsContainer
@onready var desc_box: SkillDescriptionBox = $CanvasLayer/SkillDescriptionBox
@onready var root_3 = $LayoutAnchorFixer/TripleCol

# sibling under the same Player node
@onready var player_bar: SkillsBar = (get_parent().get_node_or_null("SkillsBar")) as SkillsBar

@export var offset_position: Vector2 = Vector2(600, 0)
var _original_position: Vector2

var columns: Array
const ROWS_PER_COLUMN := 3

func _ready():
	root_3.visible = false
	columns = [col1, col2, col3]
	desc_box.visible = false

func generate_placeholder_skill_icons():
	print("[SkillsColumn] generate_placeholder_skill_icons()")
	root_3.visible = true
	
	# Connect hover signals to existing ColorRects
	for container in columns:
		for icon in container.get_children():
			_connect_hover(icon)

func _connect_hover(icon: Control) -> void:
	"""Helper to safely connect hover signals"""
	if not icon.mouse_entered.is_connected(_on_icon_hover_enter):
		icon.mouse_entered.connect(_on_icon_hover_enter.bind(icon))
	if not icon.mouse_exited.is_connected(_on_icon_hover_exit):
		icon.mouse_exited.connect(_on_icon_hover_exit.bind(icon))

func _disconnect_hover(icon: Control) -> void:
	"""Helper to safely disconnect hover signals"""
	if icon.mouse_entered.is_connected(_on_icon_hover_enter):
		icon.mouse_entered.disconnect(_on_icon_hover_enter)
	if icon.mouse_exited.is_connected(_on_icon_hover_exit):
		icon.mouse_exited.disconnect(_on_icon_hover_exit)

func _on_icon_hover_enter(icon: Control):
	# Check if this icon has a real skill assigned
	var skill = icon.get_meta("skill", null)
	
	if skill != null and skill is Skill:
		# Real skill - use the proper method
		var icon_texture = null
		if icon is TextureRect:
			icon_texture = icon.texture
		
		# Get the global position of the icon for positioning
		var icon_global_pos = get_viewport().get_mouse_position() + Vector2(20, 20)
		desc_box.global_position = get_viewport().get_mouse_position() + Vector2(20, 20)
		desc_box.show_for_skill(skill, icon_texture, icon_global_pos)
	
	# Placeholder case (ColorRect with no skill)
	elif icon is ColorRect:
		desc_box.icon_tex.texture = null
		desc_box.name_label.text = "Empty Slot"
		desc_box.description_label.text = "No skill assigned"
		desc_box.base_label.text = ""
		desc_box.bonus_label.text = ""
		desc_box.coins_label.text = ""
		desc_box.odds_label.text = ""
		desc_box.global_position = get_viewport().get_mouse_position() + Vector2(20, 20)
		desc_box.visible = true
	
	# Label case (if you're using labels for some reason)
	elif icon is Label:
		desc_box.icon_tex.texture = null
		var px = icon.get_meta("px_code", icon.text)
		desc_box.name_label.text = px
		desc_box.description_label.text = ""
		desc_box.global_position = get_viewport().get_mouse_position() + Vector2(20, 20)
		desc_box.visible = true

func _on_icon_hover_exit(icon: Control):
	desc_box.hide_box()

# ASSIGN REAL SKILLS AND CONNECT HOVER EVENTS
func show_skills(player: Entity) -> void:
	print("\n[SkillsColumn] show_skills() for", player.name)
	
	# Make the skills column visible
	root_3.visible = true
	
	var skills = player.skills
	var skill_index := 0
	
	print("  Total skills found =", skills.size())
	
	for col_i in range(columns.size()):
		var container = columns[col_i]
		print("  DEBUG: Column", col_i, "has", container.get_child_count(), "children")
		
		for row_i in range(container.get_child_count()):
			var icon = container.get_child(row_i)
			
			# Disconnect any existing signals
			_disconnect_hover(icon)
			
			# Reset metadata
			icon.set_meta("skill", null)
			
			if skill_index >= skills.size():
				# No skill for this slot - leave as placeholder
				print("    [-] No skill for Column", col_i + 1, "Row", row_i + 1, "(empty slot)")
				# Reconnect hover for empty slots
				_connect_hover(icon)
				continue
			
			# Assign real skill
			var skill: Skill = skills[skill_index]
			icon.set_meta("skill", skill)
			
			print("    [+] Skill assigned -> Column", col_i + 1,
				  "Row", row_i + 1, "SkillID =", skill.skill_id)
			
			# Set real texture if provided and icon is TextureRect
			if icon is TextureRect and skill.icon_texture:
				icon.texture = skill.icon_texture
				print("       Set icon texture:", skill.icon_texture.resource_path)
			elif icon is ColorRect and skill.icon_texture:
				# If you need to convert ColorRect to TextureRect
				var tex_rect = TextureRect.new()
				tex_rect.texture = skill.icon_texture
				tex_rect.custom_minimum_size = icon.custom_minimum_size
				tex_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
				tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				tex_rect.set_meta("skill", skill)
				
				# Replace the ColorRect with TextureRect
				var idx = icon.get_index()
				container.remove_child(icon)
				container.add_child(tex_rect)
				container.move_child(tex_rect, idx)
				icon.queue_free()
				icon = tex_rect
			
			# Connect hover events for this skill
			_connect_hover(icon)
			print("       Hover connected.")
			
			skill_index += 1
	
	print("[SkillsColumn] Skill assignment complete.\n")

func hide_skills() -> void:
	"""Hide the skills column and description box"""
	root_3.visible = false
	desc_box.hide_box()
