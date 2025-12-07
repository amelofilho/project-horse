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
			print ("heads! add ", skill.bonus_roll, " to calc")
		else:
			print ("tails!")
	
	var total := int(skill.base_roll + heads * skill.bonus_roll)
	return {
		"total": total,
		"heads": heads,
		"coins": active_coins,
	}


# Public helper for direct (non-clash) damage rolls
func roll_skill_for_damage(skill) -> Dictionary:
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
	
	return result
