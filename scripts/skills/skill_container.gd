class_name SkillContainer
extends Node

func get_all_skills() -> Array[Skill]:
	"""Returns all skill nodes as children"""
	var skill_array: Array[Skill] = []
	for child in get_children():
		if child is Skill:
			skill_array.append(child)
	return skill_array

func get_expanded_skills() -> Array[Skill]:
	"""Returns skills expanded by their copies_in_deck count"""
	var expanded: Array[Skill] = []
	
	for child in get_children():
		if not child is Skill:
			continue
		
		var skill: Skill = child as Skill
		
		# Add this skill multiple times based on copies_in_deck
		var copies = skill.copies_in_deck if skill.copies_in_deck > 0 else 1
		for i in range(copies):
			expanded.append(skill)
	
	return expanded

func get_skill_count() -> int:
	"""Returns total number of skill slots (with copies)"""
	var count = 0
	for child in get_children():
		if child is Skill:
			count += child.copies_in_deck if child.copies_in_deck > 0 else 1
	return count
