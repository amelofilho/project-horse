class_name Skill
extends Node

@export var skill_id: int = 0
@export var skill_name: String = ""
@export_multiline var description: String = ""
@export var base_roll: float = 0.0
@export var bonus_roll: float = 0.0
@export var coins: int = 1
@export var odds: float = 0.5
@export var icon_texture: Texture2D

# DECK QUANTITY - How many copies of this skill appear in the deck
@export_range(1, 10) var copies_in_deck: int = 3

# Skill behavior/type (optional, for future use)
@export_enum("Attack", "Defend", "Heal", "Buff", "Debuff", "Special") var skill_type: String = "Attack"

func _init(
	_skill_id: int = 0,
	_base_roll: float = 0.0,
	_bonus_roll: float = 0.0,
	_coins: int = 1,
	_odds: float = 0.5
):
	skill_id = _skill_id
	base_roll = _base_roll
	bonus_roll = _bonus_roll
	coins = _coins
	odds = _odds

func _to_string() -> String:
	return 'Skill(skill_id=%d, base_roll=%.3f, bonus_roll=%.3f, coins=%d, odds=%.3f)' % \
			[skill_id, base_roll, bonus_roll, coins, odds]

func clash_value() -> float:
	var value: float = base_roll
	for coin_ct in range(coins):
		value += bonus_roll if heads() else 0.0
	return value

func heads() -> bool:
	return odds < randf()

func deduct_coin() -> void:
	coins = max(coins - 1, 0)

func get_display_name() -> String:
	"""Get the display name of the skill"""
	return skill_name if skill_name != "" else "Skill #%d" % skill_id

func get_odds_string() -> String:
	"""Get formatted odds as percentage"""
	return "%.0f%%" % (odds * 100.0)
