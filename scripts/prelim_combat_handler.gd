class_name PrelimCombatHandler
extends Node

const PLAYER1_SCENE = preload("res://scenes/entities/player1.tscn")
const PLAYER2_SCENE = preload("res://scenes/entities/player2.tscn")
const ENEMY_SCENE = preload("res://scenes/entities/boss.tscn")
const MAX_PLAYERS: int = 2
const MAX_SKILL_SLOTS: int = 3

var players: Array[Entity] = []
var enemy: Entity

func setup_fight() -> void:
	spawn_players() # generates players instances with all UI child scenes
	spawn_enemy() # generates enemy instance with all UI child scenes
	init_skills() # Setup skills for all entities
	apply_skills_to_UI() # inserts placeholder skill icons in UI


func spawn_players() -> void:
	#var player_positions = [Vector2(-450, -200), Vector2(-400, 150)]
	var player_positions = [Vector2(-600, -150), Vector2(-150, -150)]
	
	for i in range(MAX_PLAYERS):
		var player_instance: Entity
		if i == 0:
			player_instance = PLAYER1_SCENE.instantiate() as Entity
		else:
			player_instance = PLAYER2_SCENE.instantiate() as Entity

		player_instance.global_position = player_positions[i]
		player_instance.name = "Player_%d" % (i + 1)
		
		add_child(player_instance)
		players.append(player_instance)
		
		#generate skills bar for player instance
		var bar = player_instance.get_node_or_null("SkillsBar")
		if bar:
			bar.generate_placeholder_skill_icons()
			
		#generate skills column for player instance
		var col = player_instance.get_node_or_null("SkillsColumn")
		if col:
			col.generate_placeholder_skill_icons()
			
		print("Player %d Generated!\n" % (i + 1))

func spawn_enemy() -> void:
	var enemy_position = Vector2(200, 0)
	enemy_position = Vector2(600, -150)
	
	var enemy_instance = ENEMY_SCENE.instantiate() as Entity
	enemy_instance.global_position = enemy_position
	enemy_instance.name = "Enemy"
	
	add_child(enemy_instance)
	enemy = enemy_instance
	
	var bar: BossSkillsBar = enemy_instance.get_node_or_null("SkillsBar")
	if bar:
		bar.show_bar()
	else:
		push_error("Boss has NO SkillsBar node!")
		

func init_skills() -> void:
	# Get skills from each player's SkillContainer
	for player in players:
		var skill_container = player.get_node_or_null("SkillContainer")
		if skill_container == null:
			print("[ERROR] No SkillContainer found for", player.name)
			continue
		
		if skill_container is SkillContainer:
			# Get all unique skills
			var all_skills = skill_container.get_all_skills()
			
			# Store 3 separate column pools (each with 12 skills)
			var column_pools = []
			
			for col_idx in range(3):
				var column_pool = []
				
				# For each skill, add copies to this column's pool
				for skill in all_skills:
					var copies = skill.copies_in_deck if skill.copies_in_deck > 0 else 1
					for i in range(copies):
						column_pool.append(skill)
				
				column_pools.append(column_pool)
				print("[init_skills]", player.name, "Column", col_idx + 1, "pool:", column_pool.size(), "skills")
			
			# Store the column pools
			player.set_meta("column_pools", column_pools)
			
			print("[init_skills]", player.name, "initialized with 3 column pools")
		else:
			print("[ERROR] SkillContainer is not of type SkillContainer for", player.name)
		
		# Max skills per turn
		player.max_skill_slots = MAX_SKILL_SLOTS
	
	# Get skills from enemy's SkillContainer
	var enemy_skill_container = enemy.get_node_or_null("SkillContainer")
	if enemy_skill_container == null:
		print("[ERROR] No SkillContainer found for enemy")
		return
	
	if enemy_skill_container is SkillContainer:
		enemy.skills = enemy_skill_container.get_expanded_skills()
		print("[init_skills] Enemy loaded", enemy.skills.size(), "skills from SkillContainer")
	else:
		print("[ERROR] Enemy SkillContainer is not of type SkillContainer")


func apply_skills_to_UI():
	print("Populating skill columns with random skills...")
	for player in players:
		var col := player.get_node_or_null("SkillsColumn")
		if col:
			# Populate each column with random skills from the pool
			_populate_columns_with_random_skills(player, col)
		else:
			print("[ERROR] SkillsColumn not found for", player.name)

# New helper function to populate columns with random skills from separate column pools
func _populate_columns_with_random_skills(player: Entity, skills_column: SkillsColumn):
	print("\n[_populate_columns] Filling columns for", player.name)
	
	# Get the column pools
	var column_pools: Array = player.get_meta("column_pools", [])
	
	if column_pools.is_empty():
		print("[ERROR] No column pools found for", player.name)
		return
	
	# Each column draws from its own pool
	var columns_data = []
	
	for col_idx in range(3):
		var column_skills = []
		
		if col_idx >= column_pools.size():
			print("  [ERROR] Column", col_idx + 1, "pool missing!")
			columns_data.append(column_skills)
			continue
		
		var pool: Array = column_pools[col_idx]
		
		if pool.is_empty():
			print("  [WARN] Column", col_idx + 1, "pool is empty!")
			columns_data.append(column_skills)
			continue
		
		# Shuffle this column's pool
		var shuffled = pool.duplicate()
		shuffled.shuffle()
		
		# Take 3 random skills from this column's pool
		for slot_idx in range(min(3, shuffled.size())):
			column_skills.append(shuffled[slot_idx])
		
		columns_data.append(column_skills)
		print("  Column", col_idx + 1, "drew", column_skills.size(), "skills from its pool of", pool.size())
	
	# Now populate the UI
	_apply_column_skills_to_ui(player, skills_column, columns_data)


# Helper to apply the column skills to the actual UI
func _apply_column_skills_to_ui(player: Entity, skills_column: SkillsColumn, columns_data: Array):
	skills_column.root_3.visible = true
	
	for col_idx in range(skills_column.columns.size()):
		var container: GridContainer = skills_column.columns[col_idx]
		var column_skills = columns_data[col_idx]
		
		for row_idx in range(container.get_child_count()):
			if row_idx >= column_skills.size():
				break
			
			var icon = container.get_child(row_idx)
			var skill: Skill = column_skills[row_idx]
			
			# Disconnect old signals
			skills_column._disconnect_hover(icon)
			
			# Convert ColorRect/Label to TextureRect with skill icon
			if icon is ColorRect or icon is Label:
				var tex_rect := TextureRect.new()
				tex_rect.texture = skill.icon_texture
				tex_rect.custom_minimum_size = icon.custom_minimum_size
				tex_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
				tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				tex_rect.mouse_filter = Control.MOUSE_FILTER_STOP
				
				# Replace old node with TextureRect
				var idx = icon.get_index()
				container.remove_child(icon)
				icon.queue_free()
				container.add_child(tex_rect)
				container.move_child(tex_rect, idx)
				icon = tex_rect
			elif icon is TextureRect:
				# Update existing TextureRect
				icon.texture = skill.icon_texture
			
			# Store metadata
			icon.set_meta("skill", skill)
			icon.set_meta("px_code", "P%d" % skill.skill_id)
			
			# Connect hover events
			skills_column._connect_hover(icon)
			
			print("    [+] Column", col_idx + 1, "Row", row_idx + 1, "- Skill", skill.skill_id)
