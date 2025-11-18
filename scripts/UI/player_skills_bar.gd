# player_skills_bar.gd
class_name SkillsBar
extends Control

@export var y_offset := -130

@onready var bar_3: Control = $TripleSkills
#no longer needed as fixed to 3 skills per char. 
#@onready var bar_2: Control = $DoubleSkills
#@onready var bar_1: Control = $SingleSkills

func _ready():
	# position skill boxes y above player
	position.y = y_offset


# Call this from Player.gd
func show_bar():
	# Hide all
	#bar_1.visible = false
	#bar_2.visible = false
	#bar_3.visible = false
	
	bar_3.visible = true
	
	# Show the correct one
	#match power:
		#1: bar_1.visible = true
		#2: bar_2.visible = true
		#3: bar_3.visible = true
		#_: bar_1.visible = true   # fallback
