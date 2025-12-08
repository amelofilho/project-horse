## Idea: this is a 2 character scene. First speaker to enter is on left,
## second speaker on right. If only one speaker, only render left.
class_name DialogueCutscene
extends Control

## Map character name to its portrait. Might move somewhere else later
## core logic will not change. We may also explore passing Entity
## date directly as part of dialogue to remove this config entirely.
@export var figure_map: Dictionary[String, SpriteFrames] = { }

## Reference to figures. Use methods to access. No touch direct (prefer).
var figures: Array[DialogueFigure] = []

## Current speaking figure name
var current_speaker_name: String = ""

@onready var figure_nodes_container: CanvasLayer = $RenderedFigures


func _ready() -> void:
	if not figure_nodes_container:
		print("DialogueCutscene._ready() - figure nodes not loaded???")
		return

	# Add figure_node references to the figures array varaible
	_load_figures()
	print("figures loaded")
	hide_figures()


## Use this method to emphasis speaking figure during cutscene. Call once
## per dialogue line.
func set_focus(figure_name: String) -> void:
	if figure_name == current_speaker_name:
		# no change
		return

	var next_figure := _find_figure_by_name(figure_name)
	var current_figure := _find_figure_by_name(current_speaker_name)

	# first figure or new figure.
	if not current_figure and current_speaker_name == "" or not next_figure:
		# render figure
		next_figure = await render_figure(figure_name)

	# new figure is already rendered in scene from earlier
	elif next_figure:
		pass # don't care

	elif not current_figure and current_speaker_name != "":
		# if trigger, probably didn't load in figures correctly
		print("DialogueCutscene.set_focus() - missing current speaker figure.")

	# Flip the new speaker to focus
	next_figure.set_figure_state(DialogueFigure.FIGURE_STATE.FOCUS)

	# Flip the old speaker to non-focus (if possible)
	if current_figure:
		current_figure.set_figure_state(DialogueFigure.FIGURE_STATE.NONE)

	_set_speaker(figure_name)


## Remove all the DialogueFigure references from figures.
func empty_figures() -> void:
	figures.clear()


## Disable all figure visbility.
func hide_figures() -> void:
	for node: Node in figure_nodes_container.get_children():
		if node is DialogueFigure:
			node.hide()


## Check if all the figures are rendered. All rendered means
## if can't find figure by name then need swap out for space.
func is_all_rendered() -> bool:
	var all_rendered: bool = true

	for figure: DialogueFigure in figures:
		if not figure.visible:
			all_rendered = false
			break

	return all_rendered


## Iterates through dialogue figure references and returns
## the index of the first available figure location left to right.
## If no positions are avaiable, returns -1.
func find_free_figure_position() -> int:
	var idx: int = -1

	for i: int in range(len(figures)):
		var figure: DialogueFigure = figures[i]

		if not figure.visible:
			idx = i
			break

	return idx


## Get the sprite frames for a specific figure
func get_sprite_frames(figure_name: String) -> SpriteFrames:
	var sprite_frames: SpriteFrames = figure_map.get(figure_name)

	if not sprite_frames:
		print("DialogueCutscene.get_sprite_frames() - %s no sprite frames" % figure_name)

	return sprite_frames


## Displays the character in the cutscene. Returns the reference to
## the render. Not rlly needed to be called directly, use set_focus()
## should be ok for all needs. In fact, direct use this method might bug...
func render_figure(figure_name: String) -> DialogueFigure:
	# Not all figures are rendered
	if not is_all_rendered():
		var free_idx: int = find_free_figure_position()

		if free_idx == -1:
			print("Wait wtf how? Figures not all render yet no free. DEBUG!!")
			return

		var new_figure: DialogueFigure = figures[free_idx]

		# set name
		new_figure.set_figure_name(figure_name)

		var figure_sprite_frames: SpriteFrames = get_sprite_frames(figure_name)

		# set the figure's sprite frames
		new_figure.set_sprite_frames(figure_sprite_frames)

		# display the figure - emphasis is controlled in set_focus()
		new_figure.show()

		# some cursed ai trick to make it load
		await get_tree().create_timer(0.01).timeout # forces at least one full physics/layout

		new_figure._calibrate_sprite_size()

		return new_figure

	# All figures are rendered. Need retire a old one
	else:
		# retire unused figure
		_shift_figures()

		#retry
		return await render_figure(figure_name)


## Set background to cutscene
func set_background(texture: Texture2D) -> void:
	var bg: TextureRect = figure_nodes_container.get_node("Background")
	bg.texture = texture


## Helper function load figure node references into array
func _load_figures() -> void:
	for node: Node in figure_nodes_container.get_children():
		if node is DialogueFigure:
			figures.append(node)


func _find_figure_by_name(figure_name: String) -> DialogueFigure:
	var matching_figure: DialogueFigure = null

	for figure: DialogueFigure in figures:
		if figure.figure_name == figure_name:
			matching_figure = figure

	return matching_figure


func _set_speaker(speaker_name: String) -> void:
	current_speaker_name = speaker_name


## Helper function for render_figure(). Don't worry about it.
func _shift_figures() -> void:
	var prev_figure: DialogueFigure = figures[0]
	var figures_length: int = len(figures)

	# Push each figure's defining attributes right
	for figure_idx: int in range(1, figures_length):
		if figure_idx >= figures_length:
			break

		var figure: DialogueFigure = figures[figure_idx]

		# backup
		var tmp_sprite_frames: SpriteFrames = figure.get_sprite_frames()
		var tmp_figure_name: String = figure.get_figure_name()

		# push right
		figure.set_sprite_frames(prev_figure.get_sprite_frames())
		figure.set_figure_name(prev_figure.get_figure_name())

		# update previous figure
		prev_figure.set_sprite_frames(tmp_sprite_frames)
		prev_figure.set_figure_name(tmp_figure_name)

	# left most figure is retired (aka. top most in scene)
	var left_figure: DialogueFigure = figures[0]

	left_figure.hide()
	left_figure.set_figure_state(DialogueFigure.FIGURE_STATE.NONE)
