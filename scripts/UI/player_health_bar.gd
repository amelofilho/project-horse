# player_health_bar.gd
class_name HealthBar
extends Control  

# --- Signals ---
signal health_changed(current:int, max:int)
signal died

# --- Exported inspector values ---

# custom portrait per HUD instance
@export var portrait_texture: Texture2D:
	set(value):
		portrait_texture = value
		if $PortraitContainer/Portrait:
			$PortraitContainer/Portrait.texture = value

# custom player name per HUD instance
@export var player_name: String = "":
	set(value):
		player_name = value
		if $Name:
			$Name.text = value

# Maximum health per character
@export var max_health:int = 100

# Cached node references
@onready var bar: ProgressBar = $HealthBar
@onready var label: Label = $HealthValue

# --- Runtime variables ---
var current_health: int

# --- Initialization ---
func _ready() -> void:
	current_health = max_health
	_update_bar()
	emit_signal("health_changed", current_health, max_health)
	
	# Apply portrait when scene loads
	if portrait_texture:
		$PortraitContainer/Portrait.texture = portrait_texture
	
	# Apply player name when scene loads
	if player_name != "":
		$Name.text = player_name

# --- Updates healthbar visuals ---
func _update_bar() -> void:
	bar.max_value = max_health
	bar.value = current_health
	label.text = "%d / %d" % [current_health, max_health]

	# color change by health %
	# var ratio := float(current_health) / max_health
	# var fill := bar.get_theme_stylebox("fill")
	# if fill is StyleBoxFlat:
	#     if ratio < 0.25:
	#         fill.bg_color = Color(0.8, 0.1, 0.1) # red
	#     elif ratio < 0.6:
	#         fill.bg_color = Color(0.9, 0.7, 0.1) # yellow
	#     else:
	#         fill.bg_color = Color(0.1, 0.8, 0.1) # green
	# bar.add_theme_stylebox_override("fill", fill.duplicate())

# --- Decrease health by damage amount ---
func apply_damage(amount: int) -> void:
	current_health = max(current_health - amount, 0)
	_update_bar()
	emit_signal("health_changed", current_health, max_health)
	print("Taken 10 damage")
	if current_health == 0:
		emit_signal("died")

# --- Increase health by heal amount ---
func heal(amount: int) -> void:
	current_health = min(current_health + amount, max_health)
	_update_bar()
	emit_signal("health_changed", current_health, max_health)
	print("Healed 10 damage")

# --- Debug buttons for testing ---
func _on_damage_pressed() -> void:
	apply_damage(10)

func _on_heal_pressed() -> void:
	heal(10)
