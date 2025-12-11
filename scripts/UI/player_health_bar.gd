class_name HealthBar
extends Control

var entity: Entity

@onready var bar: ProgressBar = $HealthBar
@onready var label: Label = $HealthValue
@onready var portrait_node: TextureRect = $PortraitContainer/Portrait


func _ready() -> void:
	entity = get_parent()
	_update_bar()
	bar.value = int(entity.max_hp)


# update health bar with parent's hp
func _update_bar() -> void:
	if entity == null:
		return

	var current := int(entity.current_hp)
	var max_hp := int(entity.max_hp)

	bar.max_value = max_hp
	bar.value = current
	label.text = "%d / %d" % [current, max_hp]


# method called on damage
func refresh() -> void:
	_update_bar()
