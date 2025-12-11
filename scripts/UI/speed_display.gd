class_name SpeedDisplay
extends Control

var entity: Entity

@onready var label: Label = $SpeedValue


func _ready() -> void:
	entity = get_parent()
	update()


# update speed display
func update() -> void:
	if entity == null:
		return
	var speed := int(entity.get_current_speed())
	label.text = "Speed: %d" % [speed]
