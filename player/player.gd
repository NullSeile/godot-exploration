extends CharacterBody3D
class_name Player

const SPEED = 300.0
const JUMP_VELOCITY = 4.5

var desired_angle: float = 0
var on_dialogue: bool = false

var current_interactable = null

enum HairStyle { BOB, SHORT, TOUPE }
var hair_styles = {
	HairStyle.BOB: preload("res://player/animation/hair/hair_bob_atlas.png"),
	HairStyle.SHORT: preload("res://player/animation/hair/hair_short_atlas.png"),
	HairStyle.TOUPE: preload("res://player/animation/hair/hair_toupe_atlas.png"),
}

enum HeadStyle { HUMAN, CANINE, FELINE }
var head_styles = {
	HeadStyle.HUMAN: preload("res://player/animation/head/head_human_atlas.png"),
	HeadStyle.CANINE: preload("res://player/animation/head/head_canine_atlas.png"),
	HeadStyle.FELINE: preload("res://player/animation/head/head_feline_atlas.png"),
}

enum EyeStyle { EYE1, EYE2, EYE3, EYE4, EYE5, EYE6, EYE7 }
var eye_styles = {
	EyeStyle.EYE1: preload("res://player/animation/eyes/eyes1_atlas.png"),
	EyeStyle.EYE2: preload("res://player/animation/eyes/eyes2_atlas.png"),
	EyeStyle.EYE3: preload("res://player/animation/eyes/eyes3_atlas.png"),
	EyeStyle.EYE4: preload("res://player/animation/eyes/eyes4_atlas.png"),
	EyeStyle.EYE5: preload("res://player/animation/eyes/eyes5_atlas.png"),
	EyeStyle.EYE6: preload("res://player/animation/eyes/eyes6_atlas.png"),
	EyeStyle.EYE7: preload("res://player/animation/eyes/eyes7_atlas.png"),
}

enum BottomStyle { PANTS, SHORTS, SKIRT }
var bottom_styles = {
	BottomStyle.PANTS: preload("res://player/animation/bottom/bottom_pants_atlas.png"),
	BottomStyle.SHORTS: preload("res://player/animation/bottom/bottom_shorts_atlas.png"),
	BottomStyle.SKIRT: preload("res://player/animation/bottom/bottom_skirt_atlas.png"),
}

@export var hair_style: HairStyle = HairStyle.BOB
@export var head_style: HeadStyle = HeadStyle.HUMAN
@export var eye_style: EyeStyle = EyeStyle.EYE1
@export var bottom_style: BottomStyle = BottomStyle.PANTS

@export var hair_color: Color = Color(0.569, 0.349, 0.796)
@export var skin_color: Color = Color(1, 0.753, 0.949)
@export var eye_color: Color = Color(0.784, 0.435, 0.71)
@export var eye_white_color: Color = Color(1, 0.89, 0.97)
@export var shirt_color: Color = Color(0.835, 0.533, 0.878)
@export var pants_color: Color = Color(0.573, 0.349, 0.8)
@export var snout_color: Color = Color(0.784, 0.435, 0.71)

@onready var main_scene: MainScene = get_tree().current_scene

@onready var camera_host: PhantomCameraHost = $Camera3D/PhantomCameraHost


func set_interactable(node: Node) -> void:
	current_interactable = node


func _ready() -> void:
	DialogueManager.dialogue_started.connect(func(_a): on_dialogue = true)
	DialogueManager.dialogue_ended.connect(func(_a): on_dialogue = false)
	$UI/interact.hide()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		if current_interactable:
			current_interactable.interact()

	if event.is_action_pressed("test1"):
		main_scene.save_game()

	if event.is_action_pressed("test2"):
		main_scene.save_game()
		main_scene.change_world(
			"res://levels/character_custom/character_customization.tscn", "SpawnPoint"
		)

	if event.is_action_pressed("test3"):
		main_scene.load_game()


func shaded(color: Color) -> Color:
	color.ok_hsl_l = max(0, color.ok_hsl_l - 0.06)
	color.ok_hsl_s += 0.01
	return color


func blend(color: Color, other: Color, alpha: float) -> Color:
	color.a = alpha
	other.a = 1.0 - alpha
	return color.blend(other)


func _process(delta: float) -> void:
	$UI/interact.visible = true if current_interactable and not on_dialogue else false

	if velocity.x > 0:
		desired_angle = 0
	elif velocity.x < 0:
		desired_angle = -PI

	$Body/Hair.material_override.set_shader_parameter("current_atlas", hair_styles[hair_style])
	$Body/Head.material_override.set_shader_parameter("current_atlas", head_styles[head_style])
	$Body/Eyes.material_override.set_shader_parameter("current_atlas", eye_styles[eye_style])
	$Body/Bottom.material_override.set_shader_parameter(
		"current_atlas", bottom_styles[bottom_style]
	)

	if head_style != HeadStyle.HUMAN:
		$Body/Hair.hide()
	else:
		$Body/Hair.show()

	(
		$Body/Hair
		. material_override
		. set_shader_parameter(
			"colors",
			[
				hair_color,
				shaded(hair_color),
				blend(hair_color, skin_color, 0.7),
				blend(shaded(hair_color), shaded(skin_color), 0.7),
			]
		)
	)
	(
		$Body/Body
		. material_override
		. set_shader_parameter(
			"colors",
			[
				skin_color,
				shaded(skin_color),
			]
		)
	)
	(
		$Body/Head
		. material_override
		. set_shader_parameter(
			"colors",
			[
				skin_color,
				shaded(skin_color),
				snout_color,
			]
		)
	)
	var blush_color = skin_color
	blush_color.ok_hsl_l = max(0, blush_color.ok_hsl_l - 0.05)

	if blush_color.ok_hsl_h > 0.5:
		blush_color.ok_hsl_h += 0.02
	else:
		blush_color.ok_hsl_h -= 0.02

	(
		$Body/Eyes
		. material_override
		. set_shader_parameter(
			"colors",
			[
				blush_color,
				skin_color if head_style == HeadStyle.CANINE else shaded(blush_color),
				eye_color,
				eye_white_color,
				eye_white_color,
			]
		)
	)
	(
		$Body/Shirt
		. material_override
		. set_shader_parameter(
			"colors",
			[
				shirt_color,
				shaded(shirt_color),
				shirt_color,
				shaded(shirt_color),
			]
		)
	)
	(
		$Body/Bottom
		. material_override
		. set_shader_parameter(
			"colors",
			[
				pants_color,
				shaded(pants_color),
			]
		)
	)

	if absf(velocity.x) > 1.0:
		for part in $Body.get_children():
			var p: AnimatedSprite3D = part as AnimatedSprite3D
			p.play("walk")
	else:
		for part in $Body.get_children():
			var p: AnimatedSprite3D = part as AnimatedSprite3D
			p.play("idle")

	$Body.rotation.y = lerpf($Body.rotation.y, desired_angle, delta * 10)


func _physics_process(delta: float) -> void:
	if on_dialogue:
		return

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input := Input.get_axis("left", "right")
	var target := input * SPEED * delta

	if input:
		velocity.x = lerpf(velocity.x, target, delta * 20)
	else:
		velocity.x = lerpf(velocity.x, target, delta * 10)

	move_and_slide()
