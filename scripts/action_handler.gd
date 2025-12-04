class_name ActionHandler
extends Node

# Selection tracking - array of arrays
# Each player has their own array: [[skill0, skill1, skill2], [skill0, skill1, skill2]]
var player_selections: Array = [] # Array of Arrays of SkillSlots
var players_ref: Array = [] # Reference to player entities

# Boss skills visible during selection phase
var boss_skills: Array = [] # Array of SkillSlots

# Track original skill decks for refreshing
var original_skill_pool: Dictionary = { } # player -> original skills array

var entity: Entity = null
var bar_slot_defaults: Dictionary = {}

# Signals
signal all_selections_complete
signal combat_start_requested


# Setup skill selection for multiple players
func setup_selection(players: Array):
	player_selections.clear()
	players_ref = players

	# Initialize empty arrays for each player
	for player in players:
		# DO NOT refresh skill pool here - let it deplete naturally
		# Only refresh if pool is completely empty (failsafe)
		var skill_pool: Array = player.get_meta("skill_pool", [])
		if skill_pool.is_empty():
			print("[WARN]", player.name, "has empty pool - replenishing as failsafe")
			_replenish_player_deck(player)

		var player_slots: Array = []
		for i in range(player.max_skill_slots):
			player_slots.append(null)
		player_selections.append(player_slots)  # ← This line was missing!


# Store original skill pool for a player (call this during battle setup)
func store_original_pool(player: Entity):
	if player not in original_skill_pool:
		original_skill_pool[player] = player.skills.duplicate()


# Refresh a player's skill pool back to their full
func _refresh_skill_pool(player: Entity):
	if player in original_skill_pool:
		player.skills = original_skill_pool[player].duplicate()


# Set entity skills (called by BattleManager after boss AI selects)
func set_boss_skills(skills: Array):
	boss_skills = skills


func set_skill_for_slot(
		player_index: int,
		slot_index: int,
		skill: Skill,
		target_slot_index: int,
) -> bool:
	# Input Validation
	if player_index < 0 or player_index >= player_selections.size():
		print("Error: Invalid player index %d" % player_index)
		return false

	if slot_index < 0 or slot_index >= player_selections[player_index].size():
		print("Error: Invalid slot index %d for player %d" % [slot_index, player_index])
		return false

	var player = players_ref[player_index]

	# Create skill slot targeting the boss
	var skill_slot = SkillSlot.new(
		player, # user
		skill, # skill being used
		slot_index, # source_slot_index (where player places it)
		target_slot_index, # target_slot_index (which boss slot to hit)
		-1, # target_player_index (only used by the boss)
		boss_skills[0].user if boss_skills.size() > 0 else null, # target_entity (boss)
	)

	# Set the new skill slot
	player_selections[player_index][slot_index] = skill_slot

	# Check if all slots are filled
	_check_if_complete()

	return true


# Clear a specific slot (for retargeting/reselection)
func clear_slot(player_index: int, slot_index: int) -> bool:
	if player_index < 0 or player_index >= player_selections.size():
		return false

	if slot_index < 0 or slot_index >= player_selections[player_index].size():
		return false

	var old_skill_slot = player_selections[player_index][slot_index]

	player_selections[player_index][slot_index] = null
	return true


# Get the current skill slot (for UI display)
func get_slot_skill(player_index: int, slot_index: int):
	if player_index < 0 or player_index >= player_selections.size():
		return null

	if slot_index < 0 or slot_index >= player_selections[player_index].size():
		return null

	return player_selections[player_index][slot_index]


# Get boss skill for a specific slot (for UI display)
func get_boss_slot_skill(slot_index: int):
	for skill_slot in boss_skills:
		if skill_slot.source_slot_index == slot_index:
			return skill_slot
	return null


# Check if all selections are complete
func _check_if_complete():
	for player_slots in player_selections:
		for skill_slot in player_slots:
			if skill_slot == null:
				print("CANNOT START COMBAT - Empty slot(s) remaining")
				return # Still have empty slots

	# Signals that the "Start Combat" button can now be interacted with
	all_selections_complete.emit()


# Get all selected skills from all players
func get_all_selected_skills() -> Array:
	var all_skills: Array = []
	for player_slots in player_selections:
		for skill_slot in player_slots:
			if skill_slot != null:
				all_skills.append(skill_slot)
	return all_skills

func display_player_selections() -> void:
	print("\n=== PLAYER SELECTION SUMMARY ===")

	for player_index in range(player_selections.size()):
		print("\nPlayer ", player_index + 1, ":")

		var slots: Array = player_selections[player_index]

		for slot_index in range(slots.size()):
			var skill_slot: SkillSlot = slots[slot_index]

			if skill_slot == null:
				print("   Slot", slot_index, " = EMPTY")
			else:
				print("   Slot ", slot_index,
					" = Skill ", skill_slot.skill.skill_id)

# Get number of filled slots for a specific player (for UI display)
func get_filled_slot_count(player_index: int) -> int:
	if player_index < 0 or player_index >= player_selections.size():
		return 0

	var count = 0
	for skill_slot in player_selections[player_index]:
		if skill_slot != null:
			count += 1
	return count


# Get remaining selections for a specific player (for UI display)
func get_remaining_selections(player_index: int) -> int:
	if player_index < 0 or player_index >= player_selections.size():
		return 0

	var total_slots = player_selections[player_index].size()
	return total_slots - get_filled_slot_count(player_index)
	

# Get available skills for a player (for UI display)
func get_available_skills(player_index: int) -> Array:
	if player_index < 0 or player_index >= players_ref.size():
		return []

	return players_ref[player_index].skills
	
	
func populate_ui_skill_columns():
	for i in range(players_ref.size()):
		var player = players_ref[i]
		var available_skills = get_available_skills(i)

		var col = player.get_node_or_null("SkillsColumn")
		if col:
			col.populate_skill_icons(available_skills)
		else:
			print("ERROR: SkillsColumn missing from", player.name)

		
func populate_entity_skill_bar():
	print("Populating boss skills bar")
	if entity == null:
		print("ERROR: Boss reference not found in populate_entity_skill_bar()")
		return

	var bar: BossSkillsBar = entity.get_node_or_null("SkillsBar")
	if bar == null:
		print("ERROR: BossSkillsBar not found under boss")
		return

	var container: GridContainer = bar.get_node("TripleSkills/EmptySkillsContainer")
	var ui_slots := container.get_children()

	# Clear ALL UI slots back to default (ColorRect)
	for i in range(ui_slots.size()):
		var slot := ui_slots[i]

		# If slot became something from last round, restore default ColorRect
		if not slot is ColorRect:
			var rect := ColorRect.new()
			rect.color = Color(0.0339, 0.0339, 0.0339, 1)
			rect.custom_minimum_size = slot.custom_minimum_size
			container.remove_child(slot)
			slot.queue_free()
			container.add_child(rect)
			container.move_child(rect, i)

	# Apply boss_skills to their exact source_slot_index positions
	for skill_slot in boss_skills:
		var idx: int = skill_slot.source_slot_index
		if idx < 0 or idx >= ui_slots.size():
			continue

		var rect := container.get_child(idx)

		# Replace placeholder with TextureRect showing skill icon
		var tex_rect := TextureRect.new()
		tex_rect.texture = skill_slot.skill.icon_texture
		tex_rect.custom_minimum_size = rect.custom_minimum_size
		tex_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tex_rect.mouse_filter = Control.MOUSE_FILTER_STOP

		container.remove_child(rect)
		rect.queue_free()
		container.add_child(tex_rect)
		container.move_child(tex_rect, idx)

		# Store actual SkillSlot for later lookup
		tex_rect.set_meta("skill_slot", skill_slot)

		print("  [populate] Boss UI slot ", idx, " → SkillID_", skill_slot.skill.skill_id)

func prepare_preview_arrows() -> void:
	print("Generating boss preview arrows...")
	if boss_skills.is_empty():
		print("[arrows] No boss skills → no preview lines.")
		return

	if entity == null:
		print("[arrows] ERROR: No boss reference.")
		return

	var bar: BossSkillsBar = entity.get_node_or_null("SkillsBar")
	if bar == null:
		print("[arrows] ERROR: No BossSkillsBar.")
		return

	# Clear previous arrows
	for child in bar.boss_preview_arrows.get_children():
		child.queue_free()

	var container := bar.get_node("TripleSkills/EmptySkillsContainer")
	var ui_slots := container.get_children()

	for skill_slot in boss_skills:
		var start_idx: int = skill_slot.source_slot_index
		var target_player: int = skill_slot.target_player_index
		var target_slot: int = skill_slot.target_slot_index

		if start_idx < 0 or start_idx >= ui_slots.size():
			continue

		var start_node := ui_slots[start_idx]
		if start_node == null:
			continue

		# Get target player's UI slot
		if target_player < 0 or target_player >= players_ref.size():
			continue

		var player: Player = players_ref[target_player]
		var p_bar := player.get_node("SkillsBar")
		var p_container := p_bar.get_node("TripleSkills/EmptySkillsContainer")
		var p_slots := p_container.get_children()

		if target_slot < 0 or target_slot >= p_slots.size():
			continue

		var end_node := p_slots[target_slot]

		# Create arrow
		var arrow := bar.ARROW_SCENE.instantiate()
		bar.boss_preview_arrows.add_child(arrow)
		arrow.node_start = start_node
		arrow.node_end = end_node
		arrow.visible = false # only visible on hover
		
		print("[arrows] Created arrow from boss slot", start_idx, "to player", target_player, "slot", target_slot)

func _get_player_bar_slot(player_index: int, slot_index: int) -> Control:
	if player_index < 0 or player_index >= players_ref.size():
		return null

	var player: Entity = players_ref[player_index]
	var bar: SkillsBar = player.get_node_or_null("SkillsBar")
	if bar == null:
		print("\t[arrows] Player", player_index, "missing SkillsBar")
		return null

	var container: GridContainer = bar.get_node_or_null("TripleSkills/EmptySkillsContainer")
	if container == null:
		print("\t[arrows] Player", player_index, "missing EmptySkillsContainer")
		return null

	if slot_index < 0 or slot_index >= container.get_child_count():
		print("\t[arrows] Slot index", slot_index, "OOB for player", player_index)
		return null

	return container.get_child(slot_index) as Control

func register_boss_hover_signals(boss_entity: Node):
	var area := boss_entity.get_node_or_null("HoverArea")
	if area == null:
		push_error("\tBoss missing HoverArea")
		return

# used to set reference from battle manager
func set_boss_reference(b: Entity):
	entity = b
	
# Called by UI "Start Combat" button
func request_combat_start():
	combat_start_requested.emit()


# NEW METHOD: Populate the shared SkillsColumn with player skills
func populate_shared_skills_column(skills_column: SkillsColumn, player_index: int = 0) -> void:
	print("\n=== Populating Shared SkillsColumn ===")
	
	if skills_column == null:
		print("[ERROR] SkillsColumn reference is null!")
		return
	
	if player_index < 0 or player_index >= players_ref.size():
		print("[ERROR] Invalid player_index:", player_index)
		return
	
	# Make the skills column visible
	var triple_col = skills_column.get_node_or_null("LayoutAnchorFixer/TripleCol")
	if triple_col:
		triple_col.visible = true
	else:
		print("[ERROR] TripleCol not found in SkillsColumn")
	
	# Show skills for the specified player
	var player = players_ref[player_index]
	_populate_column_for_player(skills_column, player, player_index)
	
	print("=== SkillsColumn Population Complete ===\n")


# Helper: Populate skills column for a specific player\
func _populate_column_for_player(skills_column: SkillsColumn, player: Entity, player_index: int) -> void:
	print("  Populating SkillsColumn for", player.name)
	
	# Get this player's skill container
	var skill_container = player.get_node_or_null("SkillContainer")
	if skill_container == null:
		print("  [ERROR] No SkillContainer node found under", player.name)
		return
	
	# Get expanded skills (with copies)
	var skills: Array[Skill] = []
	if skill_container is SkillContainer:
		skills = skill_container.get_expanded_skills()
	else:
		print("  [ERROR] SkillContainer node is not a SkillContainer")
		return
	
	print("  Total skills to display:", skills.size())
	print("  DEBUG: skills_column.columns.size() =", skills_column.columns.size())
	
	# Assign skills to the 3x3 grid
	var skill_index := 0
	
	for col_i in range(skills_column.columns.size()):
		var container: GridContainer = skills_column.columns[col_i]
		
		if container == null:
			print("  [ERROR] Column", col_i, "is NULL!")
			continue
		
		print("  Column", col_i, "has", container.get_child_count(), "children")
		
		for row_i in range(container.get_child_count()):
			var icon = container.get_child(row_i)
			
			print("    Row", row_i, "- icon type:", icon.get_class())
			
			# Disconnect old signals
			skills_column._disconnect_hover(icon)
			
			# Clear metadata
			icon.set_meta("skill", null)
			icon.set_meta("player_index", null)
			icon.set_meta("px_code", null)
			
			if skill_index >= skills.size():
				# No more skills - leave as placeholder
				print("    [-] Column", col_i + 1, "Row", row_i + 1, "- Empty")
				skills_column._connect_hover(icon)
				continue
			
			# Get the skill
			var skill: Skill = skills[skill_index]
			
			print("    Processing skill:", skill.skill_id)
			
			# Convert ColorRect to Label with skill ID
			if icon is ColorRect:
				var label := Label.new()
				label.text = "P%d" % skill.skill_id
				label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
				label.custom_minimum_size = icon.custom_minimum_size
				label.add_theme_font_size_override("font_size", 40)
				label.add_theme_color_override("font_color", Color.BLACK)
				label.mouse_filter = Control.MOUSE_FILTER_STOP
				
				# Replace ColorRect with Label
				var idx = icon.get_index()
				container.remove_child(icon)
				icon.queue_free()
				container.add_child(label)
				container.move_child(label, idx)
				icon = label
				print("      Created new Label")
			elif icon is Label:
				# Update existing label
				icon.text = "P%d" % skill.skill_id
				print("      Updated existing Label")
			
			# Store metadata
			icon.set_meta("skill", skill)
			icon.set_meta("player_index", player_index)
			icon.set_meta("px_code", "P%d" % skill.skill_id)
			
			# Connect hover events
			skills_column._connect_hover(icon)
			
			# Connect click events for skill selection
			if not icon.gui_input.is_connected(_on_column_skill_gui_input):
				icon.gui_input.connect(
					_on_column_skill_gui_input.bind(player_index, col_i, icon)
				)
			
			print("    [+] Column", col_i + 1, "Row", row_i + 1, "- P%d" % skill.skill_id)
			
			skill_index += 1


func populate_player_skill_selection():
	print("\n=== Populating Players SkillsColumns...")
	
	for player_index in range(players_ref.size()):
		var player: Entity = players_ref[player_index]
		var skills_column: SkillsColumn = player.get_node_or_null("SkillsColumn")
		if skills_column == null:
			print("SkillsColumn missing for", player.name)
			continue

		# Get this player's full skill pool (12 skills right now)
		var pool: Array = get_available_skills(player_index)
		if pool.is_empty():
			print("    [WARN] No skills available for", player.name)
			continue

		# Make a shuffled copy of the pool
		# TODO: Check if skill pools shuffle every turn...
		var shuffled_pool: Array = pool.duplicate()
		shuffled_pool.shuffle()

		# Pick 9 skills from that pool (wrap if pool < 9)
		var needed_slots := 9
		var picked_skills: Array = []
		var idx := 0

		while picked_skills.size() < needed_slots:
			var skill: Skill = shuffled_pool[idx]
			picked_skills.append(skill)
			idx += 1
			if idx >= shuffled_pool.size():
				idx = 0 # wrap around if ever needed

		# assign 9 skills into the 3x3 grid
		var assign_index := 0

		for col_idx in range(skills_column.columns.size()):
			var col: GridContainer = skills_column.columns[col_idx]

			for row_idx in range(col.get_child_count()):
				if assign_index >= picked_skills.size():
					break

				var node: Control = col.get_child(row_idx)

				# Only replace placeholders
				if node is ColorRect:
					var skill: Skill = picked_skills[assign_index]

					var tex_rect := TextureRect.new()
					tex_rect.texture = skill.icon_texture
					tex_rect.custom_minimum_size = node.custom_minimum_size
					tex_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
					tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
					tex_rect.mouse_filter = Control.MOUSE_FILTER_STOP

					# Replace the placeholder node
					col.remove_child(node)
					node.queue_free()
					col.add_child(tex_rect)
					col.move_child(tex_rect, row_idx)

					# Store metadata
					tex_rect.set_meta("px_code", "P%d" % skill.skill_id)
					tex_rect.set_meta("skill", skill)

					# Connect hover signals
					if not tex_rect.mouse_entered.is_connected(_on_skill_hover_enter):
						tex_rect.mouse_entered.connect(_on_skill_hover_enter.bind(tex_rect, skills_column))
					if not tex_rect.mouse_exited.is_connected(_on_skill_hover_exit):
						tex_rect.mouse_exited.connect(_on_skill_hover_exit.bind(skills_column))

					assign_index += 1
	print("=== Populated Players SkillColumns successfully ===")

# Replenish a specific column when it runs out of skills
func replenish_column(player_index: int, column_index: int) -> void:
	if player_index < 0 or player_index >= players_ref.size():
		return
	
	var player: Entity = players_ref[player_index]
	var skills_column: SkillsColumn = player.get_node_or_null("SkillsColumn")
	if skills_column == null:
		return
	
	var skill_pool: Array = player.get_meta("skill_pool", [])
	if skill_pool.is_empty():
		print("[WARN] No skill pool to replenish from!")
		return
	
	var container: GridContainer = skills_column.columns[column_index]
	
	print("\n[REPLENISH] Refilling Column", column_index + 1, "for", player.name)
	
	# Fill all 3 slots in this column with random skills
	for row_idx in range(container.get_child_count()):
		var icon = container.get_child(row_idx)
		var random_skill = skill_pool.pick_random()
		
		# Convert to TextureRect if needed
		if icon is Label or icon is ColorRect:
			var tex_rect := TextureRect.new()
			tex_rect.texture = random_skill.icon_texture
			tex_rect.custom_minimum_size = icon.custom_minimum_size
			tex_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
			tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			tex_rect.mouse_filter = Control.MOUSE_FILTER_STOP
			
			# Store metadata
			tex_rect.set_meta("skill", random_skill)
			tex_rect.set_meta("px_code", "P%d" % random_skill.skill_id)
			
			# Replace old node
			var idx = icon.get_index()
			container.remove_child(icon)
			icon.queue_free()
			container.add_child(tex_rect)
			container.move_child(tex_rect, idx)
			icon = tex_rect
		elif icon is TextureRect:
			# Update existing TextureRect
			icon.texture = random_skill.icon_texture
			icon.set_meta("skill", random_skill)
			icon.set_meta("px_code", "P%d" % random_skill.skill_id)
		
		# Reconnect click handler
		if icon.gui_input.is_connected(_on_column_skill_gui_input):
			icon.gui_input.disconnect(_on_column_skill_gui_input)
		
		icon.gui_input.connect(
			_on_column_skill_gui_input.bind(player_index, column_index, icon)
		)
		
		print("  [+] Row", row_idx + 1, "refilled with Skill", random_skill.skill_id)


# Remove used skills from the player's deck permanently
func consume_used_skills() -> void:
	print("\n=== Consuming Used Skills ===")
	
	for player_index in range(player_selections.size()):
		var player = players_ref[player_index]
		var used_slots = player_selections[player_index]
		
		print("\n[consume]", player.name, "used skills:")
		
		# Get the column pools
		var column_pools: Array = player.get_meta("column_pools", [])
		
		for slot_index in range(used_slots.size()):
			var slot = used_slots[slot_index]
			
			if slot != null and slot.skill != null:
				# The slot_index corresponds to the column_index
				var column_idx = slot_index
				
				if column_idx >= column_pools.size():
					print("  [ERROR] Invalid column index", column_idx)
					continue
				
				var pool: Array = column_pools[column_idx]
				
				# Find and remove ONE instance of this skill from the column's pool
				var removed = false
				for i in range(pool.size()):
					if pool[i] == slot.skill:
						print("  - Removed Skill", slot.skill.skill_id, "from Column", column_idx + 1, "pool")
						pool.remove_at(i)
						removed = true
						break
				
				if not removed:
					print("  [WARN] Could not find skill", slot.skill.skill_id, "in Column", column_idx + 1)
		
		# Update the pools
		player.set_meta("column_pools", column_pools)
		
		# Check if any pools are empty and need replenishment
		for col_idx in range(column_pools.size()):
			var pool_size = column_pools[col_idx].size()
			print("[consume] Column", col_idx + 1, "has", pool_size, "skills remaining")
			
			if pool_size == 0:
				print("[consume] Column", col_idx + 1, "depleted! Replenishing...")
				_replenish_column_pool(player, col_idx)


# Replenish a specific column's pool when it's empty
func _replenish_column_pool(player: Entity, column_idx: int) -> void:
	var skill_container = player.get_node_or_null("SkillContainer")
	if skill_container == null or not skill_container is SkillContainer:
		print("[ERROR] Cannot replenish - no SkillContainer")
		return
	
	# Get fresh skills from SkillContainer
	var all_skills = skill_container.get_all_skills()
	var new_pool = []
	
	for skill in all_skills:
		var copies = skill.copies_in_deck if skill.copies_in_deck > 0 else 1
		for i in range(copies):
			new_pool.append(skill)
	
	# Update the specific column pool
	var column_pools: Array = player.get_meta("column_pools", [])
	if column_idx < column_pools.size():
		column_pools[column_idx] = new_pool
		player.set_meta("column_pools", column_pools)
		print("[REPLENISH] Column", column_idx + 1, "restored to", new_pool.size(), "skills")


# Replenish a player's entire deck when it's empty
func _replenish_player_deck(player: Entity) -> void:
	var skill_container = player.get_node_or_null("SkillContainer")
	if skill_container == null or not skill_container is SkillContainer:
		print("[ERROR] Cannot replenish - no SkillContainer")
		return
	
	# Get fresh skills from SkillContainer
	var all_skills = skill_container.get_all_skills()
	player.set_meta("skill_pool", all_skills.duplicate())
	
	print("[REPLENISH]", player.name, "deck restored to", all_skills.size(), "skills")

func select_player_skills() -> void:
	print("\n[select_player_skills] BEGIN attaching click handlers...")

	for player_index in range(players_ref.size()):
		var player: Entity = players_ref[player_index]

		var skills_column: SkillsColumn = player.get_node_or_null("SkillsColumn")
		if skills_column == null:
			print("[select_player_skills] MISSING SkillsColumn for", player.name)
			continue

		var bar: SkillsBar = player.get_node_or_null("SkillsBar")
		if bar == null:
			print("[select_player_skills] MISSING SkillsBar for", player.name)
			continue

		var bar_container: GridContainer = bar.get_node("TripleSkills/EmptySkillsContainer")

		# --- CONNECT column skill clicks ---
		for col_idx in range(skills_column.columns.size()):
			var col: GridContainer = skills_column.columns[col_idx]

			for row_idx in range(col.get_child_count()):
				var node := col.get_child(row_idx)
				
				# Support both TextureRect and Label
				if not (node is TextureRect or node is Label):
					print("  [WARN] Column", col_idx, "Row", row_idx, "is not a TextureRect/Label")
					continue

				node.mouse_filter = Control.MOUSE_FILTER_STOP

				# ALWAYS disconnect first (prevents duplicate connections)
				if node.gui_input.is_connected(_on_column_skill_gui_input):
					node.gui_input.disconnect(_on_column_skill_gui_input)

				node.gui_input.connect(
					_on_column_skill_gui_input.bind(player_index, col_idx, node)
				)

		# --- CONNECT bar slot clicks ---
		for slot_index in range(bar_container.get_child_count()):
			var slot_node := bar_container.get_child(slot_index) as Control
			if slot_node == null:
				continue
				
			_cache_bar_slot_default(player_index, slot_index, slot_node)

			slot_node.mouse_filter = Control.MOUSE_FILTER_STOP

			if slot_node.gui_input.is_connected(_on_bar_slot_gui_input):
				slot_node.gui_input.disconnect(_on_bar_slot_gui_input)

			slot_node.gui_input.connect(
				_on_bar_slot_gui_input.bind(player_index, slot_index)
			)
			
			print("  [+] Connected Bar Slot", slot_index, "for", player.name)
	print("[select_player_skills] DONE attaching handlers.\n")

func _on_column_skill_gui_input(
		event: InputEvent,
		player_index: int,
		column_index: int,
		node: Control
) -> void:
	var mb := event as InputEventMouseButton
	if mb == null or not mb.pressed or mb.button_index != MOUSE_BUTTON_LEFT:
		return
	
	print("\n[CLICK] Column Skill Click:",
		" Player:", player_index,
		" Col:", column_index,
		" Node type:", node.get_class())
	
	var skill: Skill = node.get_meta("skill")
	if skill == null:
		print("[ERROR] Column node has NO skill meta!")
		return
	
	var slot_index := column_index # strict column → bar-slot mapping
	var player: Player = players_ref[player_index]
	var bar: SkillsBar = player.get_node("SkillsBar")
	var skills_column: SkillsColumn = player.get_node("SkillsColumn")
	var bar_container: GridContainer = bar.get_node("TripleSkills/EmptySkillsContainer")
	var bar_node: Control = bar_container.get_child(slot_index)
	
	var existing_slot: SkillSlot = get_slot_skill(player_index, slot_index)
	
	# If the EXACT SAME node is clicked again (same column, same row), unselect it
	if existing_slot != null and existing_slot.skill == skill:
		# Check if it's the exact same node that was clicked
		var same_node = false
		var col_container: GridContainer = skills_column.columns[column_index]
		for row_idx in range(col_container.get_child_count()):
			var check_node = col_container.get_child(row_idx)
			if check_node == node and check_node.get_meta("used_in_slot", -1) == slot_index:
				same_node = true
				break
		
		if same_node:
			node.set_meta("used_in_slot", -1)  # Clear the marker
			var ok := clear_slot(player_index, slot_index)
			
			if ok:
				_reset_bar_slot_visual(player_index, slot_index)
			return
	
	# If different skill already in bar slot, clear it first
	if existing_slot != null:
		
		# Clear the "used_in_slot" marker from the old node
		for col_idx in range(skills_column.columns.size()):
			var col_container: GridContainer = skills_column.columns[col_idx]
			for row_idx in range(col_container.get_child_count()):
				var check_node = col_container.get_child(row_idx)
				if check_node.get_meta("used_in_slot", -1) == slot_index:
					check_node.set_meta("used_in_slot", -1)
		
		var ok := clear_slot(player_index, slot_index)
		if ok:
			_reset_bar_slot_visual(player_index, slot_index)
	
	# Sets new skill
	var set_ok := set_skill_for_slot(player_index, slot_index, skill, slot_index)
	
	if not set_ok:
		print("[ERROR] set_skill_for_slot FAILED")
		return
	
	# Refresh bar_node since we may have replaced it
	bar_node = bar_container.get_child(slot_index)
	
	# --- Replace ColorRect/Label with TextureRect if needed ---
	if bar_node is ColorRect:
		var tex_rect := TextureRect.new()
		tex_rect.texture = skill.icon_texture
		tex_rect.custom_minimum_size = bar_node.custom_minimum_size
		tex_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tex_rect.mouse_filter = Control.MOUSE_FILTER_STOP
		
		bar_container.add_child(tex_rect)
		bar_container.move_child(tex_rect, slot_index)
		bar_node.queue_free()
		bar_node = tex_rect
	elif bar_node is TextureRect:
		bar_node.texture = skill.icon_texture
	elif bar_node is Label:
		# Convert existing label to TextureRect
		var tex_rect := TextureRect.new()
		tex_rect.texture = skill.icon_texture
		tex_rect.custom_minimum_size = bar_node.custom_minimum_size
		tex_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tex_rect.mouse_filter = Control.MOUSE_FILTER_STOP
		
		bar_container.add_child(tex_rect)
		bar_container.move_child(tex_rect, slot_index)
		bar_node.queue_free()
		bar_node = tex_rect
	
	# Attach metadata
	bar_node.set_meta("skill", skill)
	
	# Mark which column node was used for this slot
	node.set_meta("used_in_slot", slot_index)
	
	print("[CLICK] Slot ", slot_index, " is now using skill ", skill.skill_id)


func _on_bar_slot_gui_input(event: InputEvent, player_index: int, slot_index: int) -> void:
	var mb := event as InputEventMouseButton
	if mb == null or not mb.pressed or mb.button_index != MOUSE_BUTTON_LEFT:
		return

	print("\n[CLICK] Bar Slot Click:",
		" Player:", player_index,
		" Slot:", slot_index)

	var existing_slot: SkillSlot = get_slot_skill(player_index, slot_index)
	if existing_slot == null:
		print("[CLICK] Slot already empty.")
		return

	print("[CLICK] Clearing slot", slot_index,
		" skill =", existing_slot.skill.skill_id)

	var cleared := clear_slot(player_index, slot_index)
	print("[CLICK] clear_slot() returned:", cleared)

	# Now fully restore the ColorRect
	if cleared:
		print("[CLICK] Resetting slot visual for player", player_index, "slot", slot_index)
		_reset_bar_slot_visual(player_index, slot_index)

	print("[CLICK] Slot", slot_index, "cleared.\n")
	
	
func _cache_bar_slot_default(
		player_index: int,
		slot_index: int,
		slot_node: Control
) -> void:
	var key := "%d_%d" % [player_index, slot_index]
	if bar_slot_defaults.has(key):
		return  # already cached

	var data := {
		"class": slot_node.get_class(),
		"min_size": slot_node.custom_minimum_size,
		"size": slot_node.size
	}

	if slot_node is ColorRect:
		data["color"] = (slot_node as ColorRect).color

	bar_slot_defaults[key] = data

func _reset_bar_slot_visual(player_index: int, slot_index: int) -> void:
	var player: Entity = players_ref[player_index]
	var bar: SkillsBar = player.get_node_or_null("SkillsBar")
	if bar == null:
		print(" [reset] No SkillsBar for player", player_index)
		return

	var container := bar.get_node("TripleSkills/EmptySkillsContainer") as GridContainer
	if container == null:
		print("[reset] No EmptySkillsContainer for player", player_index)
		return
	if slot_index < 0 or slot_index >= container.get_child_count():
		print("[reset] slot index OOB:", slot_index)
		return

	var key := "%d_%d" % [player_index, slot_index]
	var cfg = bar_slot_defaults.get(key, null)

	var current := container.get_child(slot_index) as Control
	if cfg == null:
		# Fallback: just clear label text/meta
		if current is Label:
			(current as Label).text = ""
		current.set_meta("skill", null)
		current.set_meta("px_code", "")
		print("[reset] no cached defaults; just cleared label for p", player_index, "slot", slot_index)
		return

	# Remove current node from container
	container.remove_child(current)
	current.queue_free()

	# Recreate original node (ColorRect)
	var new_node: Control
	if cfg["class"] == "ColorRect":
		var rect := ColorRect.new()
		rect.color = cfg.get("color", Color.BLACK)
		new_node = rect
	else:
		new_node = Control.new()

	new_node.custom_minimum_size = cfg["min_size"]
	new_node.size = cfg["size"]
	new_node.mouse_filter = Control.MOUSE_FILTER_STOP

	# Add back into the same slot index
	container.add_child(new_node)
	container.move_child(new_node, slot_index)

	# Clear any gameplay metadata
	new_node.set_meta("skill", null)
	new_node.set_meta("px_code", "")

	# Re-wire click for future selections
	if not new_node.gui_input.is_connected(_on_bar_slot_gui_input):
		new_node.gui_input.connect(
			_on_bar_slot_gui_input.bind(player_index, slot_index)
		)

	print("[reset] Restored default ColorRect for player", player_index, "slot", slot_index)


func _on_skill_hover_enter(node: Control, skills_column: SkillsColumn) -> void:
	var skill: Skill = node.get_meta("skill")
	if skill == null:
		return
	
	# Get the SkillDescriptionBox
	var desc_box = skills_column.get_node_or_null("CanvasLayer/SkillDescriptionBox")
	if desc_box == null:
		print("[HOVER] SkillDescriptionBox not found")
		return
	
	# Update the description box with skill data
	var panel = desc_box.get_node_or_null("Panel")
	if panel:
		var name_label = panel.get_node_or_null("Name")
		var desc_label = panel.get_node_or_null("SkillDescription")
		
		if name_label:
			name_label.text = skill.get_display_name()
		if desc_label:
			desc_label.text = skill.description
	
	var stats = desc_box.get_node_or_null("Stats")
	if stats:
		var base_roll = stats.get_node_or_null("BaseRoll")
		var bonus_roll = stats.get_node_or_null("BonusRoll")
		var coins = stats.get_node_or_null("Coins")
		var odds = stats.get_node_or_null("Odds")
		
		if base_roll:
			base_roll.text = "Base: %.1f" % skill.base_roll
		if bonus_roll:
			bonus_roll.text = "Bonus: %.1f" % skill.bonus_roll
		if coins:
			coins.text = "Coins: %d" % skill.coins
		if odds:
			odds.text = "Odds: %s" % skill.get_odds_string()
	
	# Show the description box
	desc_box.visible = true

func _on_skill_hover_exit(skills_column: SkillsColumn) -> void:
	# Hide the description box
	var desc_box = skills_column.get_node_or_null("CanvasLayer/SkillDescriptionBox")
	if desc_box:
		desc_box.visible = false

# Show preview arrows when hovering over boss
func _on_boss_hover_enter() -> void:
	if entity == null:
		return
	
	var bar: BossSkillsBar = entity.get_node_or_null("SkillsBar")
	if bar == null:
		return
	
	# Show all preview arrows
	for arrow in bar.boss_preview_arrows.get_children():
		arrow.visible = true

# Hide preview arrows when exiting boss hover
func _on_boss_hover_exit() -> void:
	if entity == null:
		return
	
	var bar: BossSkillsBar = entity.get_node_or_null("SkillsBar")
	if bar == null:
		return
	
	# Hide all preview arrows
	for arrow in bar.boss_preview_arrows.get_children():
		arrow.visible = false

# Connect boss hover signals to show/hide targeting arrows
func connect_boss_hover_signals() -> void:
	if entity == null:
		print("[ERROR] No boss entity to connect hover signals")
		return
	
	var hover_area = entity.get_node_or_null("HoverArea")
	if hover_area == null:
		print("[ERROR] Boss missing HoverArea node")
		return
	
	# Connect mouse_entered and mouse_exited signals
	if not hover_area.mouse_entered.is_connected(_on_boss_hover_enter):
		hover_area.mouse_entered.connect(_on_boss_hover_enter)
	
	if not hover_area.mouse_exited.is_connected(_on_boss_hover_exit):
		hover_area.mouse_exited.connect(_on_boss_hover_exit)
	
	print("[HOVER] Boss hover signals connected")


# Clear all player selections and reset UI after combat
func clear_selections_and_ui() -> void:
	print("\n=== Clearing Player Selections & UI ===")
	
	for player_index in range(player_selections.size()):
		var player: Entity = players_ref[player_index]
		var bar: SkillsBar = player.get_node_or_null("SkillsBar")
		
		if bar == null:
			print("[clear] No SkillsBar for player", player_index)
			continue
		
		var bar_container: GridContainer = bar.get_node("TripleSkills/EmptySkillsContainer")
		
		# Clear each slot in the player's selection
		for slot_index in range(player_selections[player_index].size()):
			# Clear the selection data
			player_selections[player_index][slot_index] = null
			
			# Reset the visual UI for this slot
			_reset_bar_slot_visual(player_index, slot_index)
			
			print("[clear] Player", player_index + 1, "Slot", slot_index, "cleared")
		
		# Clear the "used_in_slot" markers from column nodes
		var skills_column: SkillsColumn = player.get_node_or_null("SkillsColumn")
		if skills_column:
			for col_idx in range(skills_column.columns.size()):
				var col_container: GridContainer = skills_column.columns[col_idx]
				for row_idx in range(col_container.get_child_count()):
					var node = col_container.get_child(row_idx)
					node.set_meta("used_in_slot", -1)


# Replace only the skills that were used in combat
func replace_used_skills_in_grid() -> void:
	
	for player_index in range(player_selections.size()):
		var player: Entity = players_ref[player_index]
		var used_slots = player_selections[player_index]
		var skills_column: SkillsColumn = player.get_node_or_null("SkillsColumn")
		
		if skills_column == null:
			print("[replace] No SkillsColumn for player", player_index)
			continue
		
		var column_pools: Array = player.get_meta("column_pools", [])
		
		# For each slot that was used
		for slot_index in range(used_slots.size()):
			var slot = used_slots[slot_index]
			
			if slot == null or slot.skill == null:
				continue
			
			# slot_index corresponds to column_index
			var column_idx = slot_index
			
			if column_idx >= skills_column.columns.size():
				continue
			
			var col_container: GridContainer = skills_column.columns[column_idx]
			
			# Find which row in this column was marked as used
			for row_idx in range(col_container.get_child_count()):
				var node = col_container.get_child(row_idx)
				
				# Check if this node was used in this slot
				if node.get_meta("used_in_slot", -1) == slot_index:
					print("  [replace] Column", column_idx + 1, "Row", row_idx + 1, 
						"used Skill", slot.skill.skill_id, "- replacing")
					
					# Get a new skill from this column's pool
					if column_idx < column_pools.size():
						var pool: Array = column_pools[column_idx]
						
						if pool.is_empty():
							print("    [WARN] Column pool empty, cannot replace")
							continue
						
						var new_skill: Skill = pool.pick_random()
						
						# Update the node with the new skill
						if node is TextureRect:
							node.texture = new_skill.icon_texture
						elif node is ColorRect or node is Label:
							# Convert to TextureRect
							var tex_rect := TextureRect.new()
							tex_rect.texture = new_skill.icon_texture
							tex_rect.custom_minimum_size = node.custom_minimum_size
							tex_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
							tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
							tex_rect.mouse_filter = Control.MOUSE_FILTER_STOP
							
							var idx = node.get_index()
							col_container.remove_child(node)
							node.queue_free()
							col_container.add_child(tex_rect)
							col_container.move_child(tex_rect, idx)
							node = tex_rect
						
						# Update metadata
						node.set_meta("skill", new_skill)
						node.set_meta("px_code", "P%d" % new_skill.skill_id)
						node.set_meta("used_in_slot", -1) # Clear the used marker
						
						# Reconnect signals
						if node.gui_input.is_connected(_on_column_skill_gui_input):
							node.gui_input.disconnect(_on_column_skill_gui_input)
						
						node.gui_input.connect(
							_on_column_skill_gui_input.bind(player_index, column_idx, node)
						)
						
						# Reconnect hover signals
						if not node.mouse_entered.is_connected(_on_skill_hover_enter):
							node.mouse_entered.connect(_on_skill_hover_enter.bind(node, skills_column))
						if not node.mouse_exited.is_connected(_on_skill_hover_exit):
							node.mouse_exited.connect(_on_skill_hover_exit.bind(skills_column))
						
					
					break # Found the used node in this column, move to next slot

# Helper class representing a skill placed in a slot
class SkillSlot:
	var user # Entity performing the skill
	var skill: Skill # The skill being used
	var source_slot_index: int # Which slot this skill occupies (i.e. 0, 1, 2)
	var target_slot_index: int # Which slot is being targeted (i.e. 0, 1, 2)
	var target_player_index: int = -1 # Which player (for boss skills only)
	var target_entity # Direct reference to the entity being attacked


	func _init(
			_user,
			_skill: Skill,
			_source_slot_index: int,
			_target_slot_index: int,
			_target_player_index: int = -1,
			_target_entity = null,
	):
		user = _user
		skill = _skill
		source_slot_index = _source_slot_index
		target_slot_index = _target_slot_index
		target_player_index = _target_player_index
		target_entity = _target_entity
