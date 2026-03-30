extends Node2D

var meatballs_object: PackedScene = preload("res://minigames/meatballs/meatball.tscn")
var meatball: RigidBody2D = null

var dragging: bool = false
var cum_velocity: Vector2 = Vector2.ZERO
var counter: int = 0
var counting_down: bool = false
var num_meatballs: int = 2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$UI/MeatballCounter.text = "Count: " + str(counter)
	new_meatball()

	$Plate/Area2D.body_entered.connect(
		func(body: Node):
			if body.is_in_group("meatball"):
				counter += 1
			if counter >= num_meatballs && !counting_down:
				$Countdown.start(10)
				counting_down = true
	)

	$Plate/Area2D.body_exited.connect(
		func(body: Node):
			if body.is_in_group("meatball"):
				counter -= 1
	)

	$Countdown.timeout.connect(
		func():
			counting_down = false
			$UI/Countdown.text = "YAY"
	)


func new_meatball() -> void:
	cum_velocity = Vector2.ZERO
	meatball = meatballs_object.instantiate()
	meatball.add_to_group("meatball")
	$SpawnMeatball.add_child(meatball)

	dragging = true
	# while dragging:
	meatball.freeze = true


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		if dragging:
			dragging = false
			meatball.freeze = false
			meatball.linear_velocity = -cum_velocity * 1500
			# new_meatball()
			get_tree().create_timer(0.5).timeout.connect(new_meatball)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# if meatball.linear_velocity.length() <= 0.1:
	if dragging:
		var direction := Input.get_vector("left", "right", "up", "down")
		cum_velocity += delta * direction
		cum_velocity = cum_velocity.normalized() * clamp(cum_velocity.length(), 0, 1)
		meatball.position = cum_velocity.normalized() * (1 - exp(-cum_velocity.length() * 3)) * 100

		$Aiming.mesh.size = Vector2(cum_velocity.length() * 200, 5)
		$Aiming.position = $SpawnMeatball.position - cum_velocity * 100
		$Aiming.rotation = cum_velocity.angle()

	$UI/MeatballCounter.text = "Count: " + str(counter)

	if counting_down:
		$UI/Countdown.text = str(ceilf($Countdown.time_left))

		if counter < num_meatballs:
			$Countdown.stop()
			counting_down = false
			$UI/Countdown.text = ""

	# meatball.linear_velocity = -direction
