class_name Player
extends Entity

func _ready():
	super._ready()


func ting():
	var guardsfx := get_node_or_null("Guard")
	if guardsfx:
		$Guard.play()


func blast():
	var blastsfx := get_node_or_null("Blast")
	if blastsfx:
		$Blast.play()


func sword1():
	var swordsfx := get_node_or_null("Sword1")
	if swordsfx:
		$Sword1.play()


func sword2():
	var swordsfx := get_node_or_null("Sword2")
	if swordsfx:
		$Sword2.play()
