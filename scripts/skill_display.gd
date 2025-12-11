class_name SkillDisplay
extends Node

@onready var label_skill := $Skill_Name
@onready var label_roll := $Damage_Roll

func set_skill(skill_name: String) -> void:
	label_skill.text = skill_name

func update_roll(total: int) -> void:
	await get_tree().create_timer(1.5).timeout
	label_roll.text = str(total)
	await get_tree().create_timer(1).timeout
	clear_roll()

func clear_roll() -> void:
	label_roll.text = ""

func remove_panel():
	await get_tree().create_timer(2.5).timeout
	queue_free()
