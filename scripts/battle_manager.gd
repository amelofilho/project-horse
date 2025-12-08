class_name BattleManager
extends Node

# Possible battle states
enum State {
	PRE_BATTLE,
	SKILL_SELECTION,
	COMBAT,
	END_WIN,
	END_LOSS
}

var state: State = State.PRE_BATTLE

# Subsystems
var prelim_handler: PrelimCombatHandler
var action_handler: ActionHandler
var combat_manager: CombatManager
var clash_system: ClashSystem
var UI_Test_System: BossFightManager

# References to players and enemy
var players: Array = []
var enemy: Entity

#store clash participants
var clash_attacker
var clash_defender
var clash_loser_is_attacker:bool

@onready var coin_scene := preload("res://scenes/UI/coin.tscn")

# Initialize subsystems and start battle
func _ready():
	# Adriano's testing before moving to prelim
	#UI_Test_System = BossFightManager.new()
	#add_child(UI_Test_System)
	
	# turned off to test UI
	_initialize_subsystems()
	start_battle()


func _initialize_subsystems():
	prelim_handler = PrelimCombatHandler.new()
	add_child(prelim_handler)
	
	action_handler = ActionHandler.new()
	add_child(action_handler)
	
	# Initialize clash system
	clash_system = ClashSystem.new()
	add_child(clash_system)
	
	clash_system.clash_started.connect(_on_clash_started)
	clash_system.clash_round_resolved.connect(_on_clash_round_resolved)
	clash_system.clash_tie.connect(_on_clash_tie)
	clash_system.clash_coin_lost.connect(_on_clash_coin_lost)
	clash_system.clash_finished.connect(_on_clash_finished)
	
	# Initialize combat manager
	combat_manager = CombatManager.new()
	add_child(combat_manager)
	combat_manager.direct_attack_coins.connect(_on_direct_attack_coins)
	
	# Wire clash system into combat manager
	combat_manager.clash_system = clash_system


func start_battle():
	state = State.PRE_BATTLE
	
	# Pre-battle spawn and setup
	prelim_handler.setup_fight()
	
	# Store references
	players = prelim_handler.players
	enemy = prelim_handler.enemy
	
	# Pass references to combat manager
	combat_manager.players = players
	combat_manager.boss = enemy
	
	# Store original skill pools for all players
	for player in players:
		action_handler.store_original_pool(player)
		
	# Sets action_handlers boss ref to this one
	action_handler.set_boss_reference(enemy)
	
	_start_skill_selection()


## Skill selection phase
func _start_skill_selection():
	state = State.SKILL_SELECTION
	print("\nPhase: Skill Selection\n")
	
	# Boss selects its skills FIRST
	var boss_skills = await _get_boss_skills()
	
	# Make boss skills visible to UI
	action_handler.set_boss_skills(boss_skills)
	
	# populates empty boss skill slots with P; NP if unsuccessful
	action_handler.populate_entity_skill_bar()
	
	# Setup skill selection for all characters
	action_handler.setup_selection(players)
	
	# Generate red preview arrows. Only visible when hovering over boss/enemy entity
	action_handler.prepare_preview_arrows()
	
	# Connect boss hover to show/hide arrows
	action_handler.connect_boss_hover_signals()
	
	# Setup click handlers for skill bars
	action_handler.select_player_skills()
	
	# Wait for all character selections to complete
	# UI should call action_handler.set_skill_for_slot() multiple times
	await action_handler.all_selections_complete
	
	# display all player selections
	action_handler.display_player_selections()
	
	# Get all player skills
	var all_skills = action_handler.get_all_selected_skills()
	
	# Add boss skills to the queue
	all_skills += boss_skills
	
	# Wait for "Start Combat" button press
	print("\nWaiting for 'Start Combat' button...")
	await action_handler.combat_start_requested
	
	# Execute combat phase
	_on_skills_ready(all_skills)


# Boss AI skill selection (placeholder)
func _get_boss_skills() -> Array:
	print("Boss selecting skills and targetting players...")
	var skills: Array = []
	
	# TODO: Replace with actual boss AI logic
	# Boss creates skills that target specific player skill slots
	for boss_slot_index in range(3):
		var random_skill = enemy.skills.pick_random() if enemy.skills.size() > 0 else Skill.new(1)
		
		# Pick a random player
		var target_player_index = randi() % players.size()
		
		# Pick a random skill slot from that player
		var target_slot_index = randi() % players[target_player_index].max_skill_slots
		
		# Create boss skill targeting a specific player's specific slot
		var skill_slot = ActionHandler.SkillSlot.new(
			enemy, # user
			random_skill, # skill being used
			boss_slot_index, # source_slot_index (which boss slot being used)
			target_slot_index, # target_slot_index (which player slot to target)
			target_player_index, # target_player_index (which player to hit)
			players[target_player_index] # entity being targeted
		)
		skills.append(skill_slot)
		
	
	return skills


# Combat phase - execute all skills in speed order
func _on_skills_ready(skill_queue: Array):
	state = State.COMBAT
	print("\nPhase: Combat")
	
	# Sort all skills by user speed (highest speed first)
	skill_queue.sort_custom(func(a, b): return a.user.speed > b.user.speed)
	
	# Let combat manager resolve skills
	print("Now entering combat_manager from battle_manager")
	await combat_manager.resolve_skills(skill_queue)
	print("Combat manager has finished!")
	
	# Consume used skills from player decks (removes from column_pools)
	action_handler.consume_used_skills()
	
	# Replace only the used skills in the 3x3 grid with new ones
	action_handler.replace_used_skills_in_grid()
	
	# Clear the player selections and reset UI (clears the skill bar above players)
	action_handler.clear_selections_and_ui()
	
	# After combat, check for end
	if _check_battle_end():
		_end_battle()
	else:
		# Reset for next turn
		_start_skill_selection()


# Check if battle ended
func _check_battle_end() -> bool:
	var all_players_dead = players.all(func(p): return p.is_dead)
	var enemy_dead = enemy.is_dead
	
	return all_players_dead or enemy_dead


# Handle battle end
func _end_battle():
	if enemy.is_dead:
		state = State.END_WIN
		print("Win!")
	else:
		state = State.END_LOSS
		print("Loss!")
	
	# TODO: Add scene transitions or victory/defeat screens


func _on_start_combat_pressed() -> void:
	action_handler.request_combat_start()
	
func _on_clash_started(attacker_slot, defender_slot) -> void:
	print("Clash started: %s vs %s" % [attacker_slot.user.name, defender_slot.user.name])
	clash_attacker = attacker_slot.user
	clash_defender = defender_slot.user

func get_coin_position(coin_num: int, total_coins: int, spacing: float = 70.0) -> float:
	var centered_index := coin_num - (total_coins - 1) / 2.0
	return centered_index * spacing


func _on_clash_round_resolved(
		round_index,
		attacker_total, defender_total,
		attacker_heads, defender_heads,
		attacker_coins_left, defender_coins_left):
	
	# Spawn & animate attacker's coins
	if clash_loser_is_attacker:
		attacker_coins_left += 1
		
	for i in range(attacker_coins_left):
		var coin = coin_scene.instantiate()
		add_child(coin)
		
		# Compute horizontal offset
		var offset_x := get_coin_position(i, attacker_coins_left)
		
		# Default Y position above attacker’s head:
		var base_pos : Vector2 = clash_attacker.global_position + Vector2(0, -120)
		
		coin.global_position = base_pos + Vector2(offset_x, 0)
		
		# check if first coin should break
		if clash_loser_is_attacker and i == 0:
			coin.should_break = true
		
		# Determine heads/tails for this coin
		var is_heads :bool = i < attacker_heads
		coin.spin(is_heads)
	
	# Spawn & animate defender's coins
	if !clash_loser_is_attacker:
		defender_coins_left += 1
	for i in range(defender_coins_left):
		var coin = coin_scene.instantiate()
		add_child(coin)
		
		# Compute horizontal offset
		var offset_x := get_coin_position(i, defender_coins_left)
		
		# Default Y position above attacker’s head:
		var base_pos : Vector2 = clash_defender.global_position + Vector2(0, -120)
		
		# Now assign:
		coin.global_position = base_pos + Vector2(offset_x, 0)
		
		# check if first coin should break
		if !clash_loser_is_attacker and i == 0:
			coin.should_break = true
		
		# Determine heads/tails for this coin
		var is_heads :bool = i < defender_heads
		coin.spin(is_heads)


func _on_direct_attack_coins(user: Entity, heads: int, total_coins: int, total_dmg: int) -> void:
	for i in range(total_coins):
		var coin = coin_scene.instantiate()
		add_child(coin)
		
		var offset_x := get_coin_position(i, total_coins)
		var base_pos := user.global_position + Vector2(0, -120)
		
		coin.global_position = base_pos + Vector2(offset_x, 0)
		
		var is_heads := i < heads
		coin.spin(is_heads)


func _on_clash_tie(round_index, total) -> void:
	print("Tie in round %d! Both rolled %d" % [round_index + 1, total])


func _on_clash_coin_lost(round_index, loser_is_attacker, attacker_coins_left, defender_coins_left) -> void:
	clash_loser_is_attacker = loser_is_attacker


func _on_clash_finished(winner_slot, loser_slot, damage_total, result) -> void:
	print("Final clash roll: winner = %s, damage = %d" %
		[winner_slot.user.name, damage_total])
	
	var winner: Entity = winner_slot.user
	var dmg_detail: Dictionary = result["damage_detail"]
	
	var heads: int = dmg_detail.get("heads", 0)
	var total_coins: int = dmg_detail.get("coins", 0)
	
	# Animate all coins used in the final damage roll
	for i in range(total_coins):
		var coin = coin_scene.instantiate()
		add_child(coin)
		
		# Position above the winner's head
		var offset_x := get_coin_position(i, total_coins)
		var base_pos := winner.global_position + Vector2(0, -120)
		
		coin.global_position = base_pos + Vector2(offset_x, 0)
		
		var is_heads := i < heads
		coin.spin(is_heads)
