class_name ClashSystem
extends Node

#signals for clash states
signal clash_started(attacker_slot, defender_slot)

signal clash_round_resolved(
	round_index: int,
	attacker_total: int,
	defender_total: int,
	attacker_heads: int,
	defender_heads: int,
	attacker_coins_left: int,
	defender_coins_left: int
)

signal clash_tie(round_index: int, total: int)

signal clash_coin_lost(
	round_index: int,
	loser_is_attacker: bool,
	attacker_coins_left: int,
	defender_coins_left: int
)

signal clash_finished(
	winner_slot,
	loser_slot,
	damage_total: int,
	result: Dictionary
)

signal status(
	status_type,
	status_owner
)

var rng := RandomNumberGenerator.new()
func _ready() -> void:
	rng.randomize()

# Roll a skill's value once using the active coins
func _roll_skill(skill, active_coins: int) -> Dictionary:
	var heads := 0
	
	#roll for each coin compared against each coin
	for i in range(active_coins):
		if rng.randf() < skill.odds:
			heads += 1
			# when rolling a heads, add bonus roll on top of base roll
			print ("heads! add ", skill.bonus_roll + skill.bonus_temp, " to calc")
			
			# NOTE: status effect-related handling handled here
			if (skill.status_type != "None"):
				_handle_status_effect(skill, true)
		else:
			print ("tails!")
			
			# NOTE: status effect-related handling handled here
			if (skill.status_type != "None"):
				_handle_status_effect(skill, false)
	
	var total := int(skill.crit_mult * 
			(skill.base_roll + heads * (skill.bonus_roll + skill.bonus_temp)))
	
	return {
		"total": total,
		"heads": heads,
		"coins": active_coins,
	}


# Public helper for direct (non-clash) damage rolls
func roll_skill_for_damage(skill) -> Dictionary:
	_on_use_status_effect(skill) # NOTE: Handles [On Use] effects
	return _roll_skill(skill, int(skill.coins))


# ----------------------------------------------------
# CLASH LOGIC
# Returns:
#   {
#      "winner_slot": slot,
#      "loser_slot": slot,
#      "winner_is_attacker": bool,
#      "damage_roll": int,
#      "damage_detail": {},
#      "rounds": [ ... ]
#   }
# ----------------------------------------------------
func run_clash(attacker_slot, defender_slot) -> Dictionary:
	# get skill variables
	var attacker_skill = attacker_slot.skill
	var defender_skill = defender_slot.skill
	var attacker_coins: int = int(attacker_skill.coins)
	var defender_coins: int = int(defender_skill.coins)
	
	# NOTE: Handles [On Use] effects ONCE before clash begins
	_on_use_status_effect(attacker_skill)
	_on_use_status_effect(defender_skill)
	
	var result := {
		"attacker_slot": attacker_slot,
		"defender_slot": defender_slot,
		"rounds": [],
		"winner_slot": null,
		"loser_slot": null,
		"winner_is_attacker": false,
		"damage_roll": 0,
		"damage_detail": {},
	}
	
	emit_signal("clash_started", attacker_slot, defender_slot)
	attacker_slot.user.is_clashing = true
	attacker_slot.user.play_animation("guard")
	defender_slot.user.is_clashing = true
	defender_slot.user.play_animation("guard")
	
	await get_tree().create_timer(1).timeout
	
	var round_index := 0
	
	# ----------------------------------------------------
	# CLASH LOOP
	# ----------------------------------------------------
	while attacker_coins > 0 and defender_coins > 0:
		
		if round_index > 0:
			print ("next round!")
		
		# Roll for attacker's clash value
		print("attacker rolls:")
		var atk_roll := _roll_skill(attacker_skill, attacker_coins)
		var atk_total: int = atk_roll["total"]
		print ("attack val: ", atk_total)
		print("")
		
		# Roll for defender's clash value
		print ("defender rolls:")
		var def_roll := _roll_skill(defender_skill, defender_coins)
		var def_total: int = def_roll["total"]
		print ("defence val: ", def_total)
		print ("")
		
		# Store round result
		var round_data := {
			"round_index": round_index,
			"attacker_total": atk_total,
			"defender_total": def_total,
			"attacker_heads": atk_roll["heads"],
			"defender_heads": def_roll["heads"],
			"attacker_coins_before": attacker_coins,
			"defender_coins_before": defender_coins,
			"attacker_coins_after": attacker_coins,
			"defender_coins_after": defender_coins,
			"loser": "none"
		}
		
		# -----------------------------
		# Resolve winner of the round
		# -----------------------------
		if atk_total > def_total:
			# Defender loses a coin
			defender_coins -= 1
			print ("defender loses a coin; remaining coins: ", defender_coins)
			round_data["loser"] = "defender"
			
			emit_signal(
				"clash_coin_lost",
				round_index,
				false,  # loser_is_attacker?
				attacker_coins,
				defender_coins
			)
		
		elif def_total > atk_total:
			# Attacker loses a coin
			attacker_coins -= 1
			print("attacker loses coin; remaining coins: ", attacker_coins)
			round_data["loser"] = "attacker"
			
			emit_signal(
				"clash_coin_lost",
				round_index,
				true,  # loser_is_attacker?
				attacker_coins,
				defender_coins
			)
		
		else:
			# Tie -> reroll
			emit_signal("clash_tie", round_index, atk_total)
			print("tie!")
			defender_slot.user.play_animation("attack1")
			attacker_slot.user.play_animation("attack1")
		
		round_data["attacker_coins_after"] = attacker_coins
		round_data["defender_coins_after"] = defender_coins
		
		result["rounds"].append(round_data)
		
		emit_signal(
			"clash_round_resolved",
			round_index,
			atk_total,
			def_total,
			atk_roll["heads"],
			def_roll["heads"],
			attacker_coins,
			defender_coins
		)
		round_index += 1
		#wait to resolve round
		await get_tree().create_timer(3).timeout
		
		#play animations
		#if attacker_coins == 0 or defender_coins == 0:
			#continue
		if round_data["loser"] == "defender":
			attacker_slot.user.play_animation("attack1")
			defender_slot.user.play_animation("guard")
		elif round_data["loser"] == "attacker":
			defender_slot.user.play_animation("attack1")
			attacker_slot.user.play_animation("guard")
		else:
			attacker_slot.user.play_animation("attack1")
			defender_slot.user.play_animation("attack1")
	
	# ----------------------------------------------------
	# END OF LOOP
	# ----------------------------------------------------
	# Determine clash winner
	var winner_slot
	var loser_slot
	var winner_is_attacker := false
	var winner_remaining_coins := 0
	
	# attacker wins
	if attacker_coins > 0 and defender_coins <= 0:
		winner_slot = attacker_slot
		loser_slot = defender_slot
		winner_is_attacker = true
		print ("attacker wins!")
		winner_remaining_coins = attacker_coins
	
	# defender wins
	elif defender_coins > 0 and attacker_coins <= 0:
		winner_slot = defender_slot
		loser_slot = attacker_slot
		winner_is_attacker = false
		print ("defender wins!")
		winner_remaining_coins = defender_coins
	
	# Winner rolls final damage with remaining coins
	var damage_total := 0
	var damage_detail := {}
	
	if winner_slot != null and winner_remaining_coins > 0:
		damage_detail = _roll_skill(winner_slot.skill, winner_remaining_coins)
		damage_total = damage_detail["total"]
	
	#declare results that will be returned to combat manager
	result["winner_slot"] = winner_slot
	result["loser_slot"] = loser_slot
	result["winner_is_attacker"] = winner_is_attacker
	result["damage_roll"] = damage_total
	result["damage_detail"] = damage_detail
	
	emit_signal("clash_finished", winner_slot, loser_slot, damage_total, result)
	loser_slot.user.is_clashing = false
	loser_slot.user.play_animation("idle")
	winner_slot.user.is_clashing = false
	return result


# For skills that have "[On Use]"
func _on_use_status_effect(skill) -> void:
	
	# If skill.bonus_roll is directly modified, it affects the values for ALL skills of that type.
	# As such, this is mainly used as a way to incorporate "bonus damage for bonus roll"
	skill.bonus_temp = 0.0 
	skill.crit_mult = 1.0
	
	# Goldilocks
	if (skill.status_type == "Mana"):
		
		# Too Hot
		if (skill.skill_id == 2):
			
			# Passive 1: If below 10 Mana, lose health and gain Mana.
			# NOTE: If the player is at 1 health, this should not kill the player
			if (skill.player.resource < 10):
				skill.player.current_hp = max(skill.player.current_hp - 2, 1)
				skill.player.resource += 10
			
			# Passive 2: Consume Mana and gain Bonus DMG (up to 4 times)
			for i in range(4):
				if skill.player.resource < 5:
					break
				
				skill.player.resource -= 5
				skill.bonus_temp += 2
		
		
	elif (skill.status_type == "Adren"):
		
		# Red Rose Petals
		if (skill.skill_id == 2):
			
			# Consume Adren and gain Bonus DMG (up to 1 times)
			for i in range(1):
				if skill.player.resource < 2:
					break
				
				skill.player.resource -= 2
				skill.bonus_temp += 2
			
	# Skill not found, return
	return
			

# The alternative would be having a cascading sequence of if elses =3
func _handle_status_effect(skill, head: bool = false) -> void:
	
	# Goldilocks
	if (skill.status_type == "Mana"):
		print("Player 1's Mana: ", skill.player.resource)
		
		# Too Cold
		# If heads, gain resource.
		if (skill.skill_id == 1):
			if (head):
				skill.player.resource += 3
				emit_signal("status", skill.status_type, skill.player.resource)
			return
		
		# Just Right
		# If heads, gain 2 Mana and deal bonus damage equal to Mana
		elif (skill.skill_id == 3):
			if (head):
				skill.player.resource += 2
				skill.bonus_temp = min(skill.player.resource, 10)
			emit_signal("status", skill.status_type, skill.player.resource)
			return;
	
	elif (skill.status_type == "Adren"):
		print("Player 2's Adren: ", skill.player.resource)
		
		# Skill 1
		if (skill.skill_id == 1):
			if (head):
				skill.player.resource += 2
			emit_signal("status", skill.status_type, skill.player.resource)
			return;
		
		# Skill 2
		elif (skill.skill_id == 2):
			emit_signal("status", skill.status_type, skill.player.resource)
			return; 
		
		# Skill 3
		elif (skill.skill_id == 3):
			if (head):
				skill.crit_mult += 0.2
			emit_signal("status", skill.status_type, skill.player.resource)
			return;
		
		return;
	
	# Skill had no type (boss)
	return;
