class_name Entity
extends CharacterBody2D

# Combat state
@export var current_hp: float = 50.0
@export var max_hp: float = 50.0
var is_defending: bool = false
var is_dead: bool = false
var is_clashing: bool = false

# Skills system
@export var skills: Array[Skill] = []
var max_skill_slots: int = 3

# Movement
@export var speed_low: float = 5
@export var speed_high: float = 8
var rand_speed: float
@export var moves: int = 1 # Number of allowed moves
@export var resource: int = 0 # For status effects

# Animation and visuals
@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	current_hp = max_hp
	_initialize_skills()


# Initialize skills from SkillContainer if present
func _initialize_skills() -> void:
	var skill_container = get_node_or_null("Skills")

	if skill_container == null:
		print("[%s] No Skills node found" % name)
		return

	if not skill_container is SkillContainer:
		print("[%s] Skills node is not a SkillContainer!" % name)
		return

	# Get expanded skills (with copies)
	skills = skill_container.get_expanded_skills()

	print("[%s] Loaded %d skill slots from SkillContainer:" % [name, skills.size()])

	# Debug: Show what skills were loaded
	var skill_counts := { }
	for skill in skills:
		if skill:
			var id = skill.skill_id
			skill_counts[id] = skill_counts.get(id, 0) + 1

	for skill_id in skill_counts:
		print("  - Skill ID %d: %d copies" % [skill_id, skill_counts[skill_id]])


# Returns the current available skill pool
func get_skill_pool() -> Array[Skill]:
	return skills


# Check if entity has any skills available
func has_skills() -> bool:
	return skills.size() > 0


# Damage handling
func take_damage(amount: float) -> void:
	if is_dead:
		return

	current_hp -= amount
	current_hp = max(0.0, current_hp)

	# update health bar
	var hb := get_node_or_null("HealthBar")
	if hb:
		hb.refresh()

	play_animation("damaged")

	#play sfx
	var hurtsfx := get_node_or_null("Hurt")
	if hurtsfx:
		$Hurt.play()

	if current_hp <= 0:
		die()


# Animation control
func play_animation(anim_name: String) -> void:
	#if sprite and sprite.sprite_frames.has_animation(anim_name):
	#sprite.play(anim_name)

	if animation_player and animation_player.has_animation(anim_name):
		animation_player.play(anim_name)


# Handles death
func die() -> void:
	if is_dead:
		return

	is_dead = true
	play_animation("death")


# Gets current HP%
func get_hp_percentage() -> float:
	return (current_hp / max_hp) * 100.0


# Checks if entity is alive
func is_alive() -> bool:
	return not is_dead and current_hp > 0


func roll_speed() -> void:
	rand_speed = randf_range(speed_low, speed_high)
	#update speed display
	var sd := get_node_or_null("SpeedDisplay")
	if sd:
		sd.update()


func get_current_speed() -> int:
	return rand_speed


func _process(_delta: float) -> void:
	if !animation_player.is_playing():
		if is_clashing:
			play_animation("clash")
		else:
			play_animation("idle")
