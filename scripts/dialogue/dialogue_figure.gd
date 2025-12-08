@tool
class_name DialogueFigure
extends Control

## Indicates if the figure should have emphasis. Binary
enum FIGURE_STATE {
	NONE,
	FOCUS,
}

## Figure character name. Cutscene manager use this to identify portrait.
@export var figure_name: String = ""

@onready var sprite: AnimatedSprite2D = get_node("MarginContainer/FigureAnimatedSprite")
@onready var animation_player: AnimationPlayer = get_node('AnimationPlayer')


func _ready() -> void:
	print("Done, DialogueFigure loaded.")
	# Attach event listener for frame changed
	sprite.sprite_frames_changed.connect(_sprite_frames_changed_handler)

	# Default no emphasis
	set_figure_state(FIGURE_STATE.NONE)


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		pass


## [code]sprite_frames[/code] passed in will load into dialogue figure full
## body portrait. The animations for this portrait should be done within the
## sprite_frames itself.
func set_sprite_frames(sprite_frames: SpriteFrames) -> void:
	if not sprite:
		print("DialogueFigure.set_sprite_frames() - Figure sprite not loaded.")

	# prevent code die runtime
	if not sprite_frames:
		sprite_frames = SpriteFrames.new()

	sprite.sprite_frames = sprite_frames

	# optional, idk
	play_animation("default")

	if is_inside_tree():
		await get_tree().process_frame # wait for layout
		_calibrate_sprite_size()


## Fetches figure sprite frames.
func get_sprite_frames() -> SpriteFrames:
	if not sprite:
		print("Can't get sprite frames. No sprite.")
		return

	return sprite.sprite_frames


## Repositions the figure to loc. Use this method instead of moving
## sub-nodes directly.
func move_figure(loc: Vector2) -> void:
	position = loc


## AnimationPlayer to give the figure container some movements.
## Load and play as you please.
func get_animation_player() -> AnimationPlayer:
	return animation_player


## Flips the figure's state between focus and non-focused.
## In story-telling games this means having the figure grayed out or not.
func set_figure_state(state: FIGURE_STATE) -> void:
	match state:
		FIGURE_STATE.NONE:
			self.modulate = Color("dark_gray")
		FIGURE_STATE.FOCUS:
			self.modulate = Color("white", 1.0)


## Set dialogue figure name
func set_figure_name(new_name: String) -> void:
	figure_name = new_name


## Get dialogue figure name value
func get_figure_name() -> String:
	return figure_name


## Request sprite to play a specific animation from its sprite frames
func play_animation(animation_name: String, speed: float = 1.0) -> void:
	sprite.play(animation_name, speed)


## Background stuff, don't worry about it.
func _sprite_frames_changed_handler() -> void:
	#if Engine.is_editor_hint():
	_calibrate_sprite_size()


## Invoked whenever a new sprite_frame is updated to our animated sprite.
## Scales up the sprite to fit within container best as possible.
func _calibrate_sprite_size() -> void:
	if not sprite:
		print("DialogueFigure._calibrate_sprite_size - Figure sprite not loaded.")
		return

	if not sprite.sprite_frames:
		print("DialogueFigure._calibrate_sprite_size - sprite frames missing")
		return

	# Sprite container size information
	var sprite_container: MarginContainer = sprite.get_parent()
	var container_margin_x = sprite_container.get_theme_constant("margin_left") \
	+ sprite_container.get_theme_constant("margin_right")
	var container_margin_y = sprite_container.get_theme_constant("margin_top") \
	+ sprite_container.get_theme_constant("margin_bottom")
	var container_size: Vector2 = sprite_container.size - Vector2(container_margin_x, container_margin_y)

	# Sample a single frame for scaling reference
	var animation_name: String = sprite.animation
	# Assume sprite frames within a set are all same size
	var frame_texture: Texture2D = sprite.sprite_frames.get_frame_texture(animation_name, 0)

	if not frame_texture:
		print("Figure sprite current animation has no frames.")
		return

	var frame_size: Vector2 = frame_texture.get_size()

	# Compute sprite scaling to fit within panel
	sprite.scale = container_size / frame_size
