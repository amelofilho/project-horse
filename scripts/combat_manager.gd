class_name CombatManager
extends Node

var players: Array[Entity] = []
var boss: Entity
var clash_system: ClashSystem

signal direct_attack_coins(user: Entity, skill_name : String, heads: int, total_coins: int, total_dmg: int)

func resolve_skills(skill_queue: Array) -> void:
	print("\n--- Resolving %d skills ---" % skill_queue.size())
	
	var consumed_slots: Array = []   # SkillSlots already resolved through clash or direct attack
	
	# go through each skill in the queue
	for i in range(skill_queue.size()):
		var skill_slot = skill_queue[i]
		
		# Skip if consumed by previous clash
		if consumed_slots.has(skill_slot):
			continue
		
		# Skip if the user is dead
		if skill_slot.user.is_dead:
			print("[%s] is dead, skipping skill" % skill_slot.user.name)
			continue
		
		# Identify target
		var target: Entity = skill_slot.target_entity
		if target == null:
			print("ERROR: SkillSlot has no valid target entity!")
			continue
		
		if target.is_dead:
			print("Target %s is dead, skipping." % target.name)
			continue
		
		# CLASH DETECTION (using helper func)
		var opposing_slot = _find_opposing_slot(skill_queue, consumed_slots, skill_slot)
		
		if opposing_slot != null and clash_system != null:
			print("\n>>> CLASH DETECTED: %s ↔ %s" % [skill_slot.user.name, opposing_slot.user.name])
			
			# Run the clash
			var clash_result: Dictionary = await clash_system.run_clash(skill_slot, opposing_slot)
			
			var damage_total: int = clash_result["damage_roll"]
			var winner_is_attacker: bool = clash_result["winner_is_attacker"]
			
			print("CLASH WINNER: ")
			
			#wait for coin animation
			if winner_is_attacker:
				skill_slot.user.play_animation("attack1")
			else:
				skill_slot.user.play_animation("damaged")
			await get_tree().create_timer(1).timeout
			
			# Apply damage to the loser
			if damage_total > 0:
				if winner_is_attacker:
					var loser: Entity = opposing_slot.user
					loser.take_damage(damage_total)
					
					if skill_slot.skill.skill_id == 1:
						skill_slot.user.play_animation("combo1")
					elif skill_slot.skill.skill_id == 2:
						skill_slot.user.play_animation("combo2")
					elif skill_slot.skill.skill_id == 3:
						skill_slot.user.play_animation("combo3")
						
					skill_slot.user.is_clashing = false
					opposing_slot.user.is_clashing = false
					print("%s takes %d clash damage!" % [loser.name, damage_total])
				else:
					var loser: Entity = skill_slot.user
					loser.take_damage(damage_total)
					if opposing_slot.skill.skill_id == 1:
						opposing_slot.user.play_animation("combo1")
					elif opposing_slot.skill.skill_id == 2:
						opposing_slot.user.play_animation("combo2")
					elif opposing_slot.skill.skill_id == 3:
						opposing_slot.user.play_animation("combo3")
					opposing_slot.user.is_clashing = false
					skill_slot.user.is_clashing = false
					print("%s takes %d clash damage!" % [loser.name, damage_total])
			
			await get_tree().create_timer(2.5).timeout
			
			# Mark both skills as used
			consumed_slots.append(skill_slot)
			consumed_slots.append(opposing_slot)
			continue
		
		# direct attack (when no clash)
		print("\n>>> DIRECT ATTACK: %s → %s" % [skill_slot.user.name, target.name])
		
		if clash_system != null:
			var dmg_detail: Dictionary = clash_system.roll_skill_for_damage(skill_slot.skill)
			var dmg: int = dmg_detail["total"]
			
			var heads := int(dmg_detail["heads"])
			var total_coins := int(skill_slot.skill.coins)
			
			emit_signal("direct_attack_coins", skill_slot.user, skill_slot.skill.skill_name, heads, total_coins, dmg)
			
			#wait for coin animation
			await get_tree().create_timer(1).timeout
			
			target.take_damage(dmg)
			if skill_slot.skill.skill_id == 1:
				skill_slot.user.play_animation("combo1")
			elif skill_slot.skill.skill_id == 2:
				skill_slot.user.play_animation("combo2")
			elif skill_slot.skill.skill_id == 3:
				skill_slot.user.play_animation("combo3")
			print("%s deals %d damage to %s" %
				[skill_slot.user.name, dmg, target.name])
				
			await get_tree().create_timer(1.5).timeout
		
		consumed_slots.append(skill_slot)
		
		if target.is_dead:
			print("%s has been defeated!" % target.name)


# Helper function: Find the skill slot belonging to the target entity
func _find_opposing_slot(skill_queue: Array, consumed_slots: Array, current_slot):
	var current_target: Entity = current_slot.target_entity
	if current_target == null:
		return null
	
	for slot in skill_queue:
		if slot == current_slot:
			continue
		if consumed_slots.has(slot):
			continue
		if slot.user == current_target:
			return slot
	
	return null
