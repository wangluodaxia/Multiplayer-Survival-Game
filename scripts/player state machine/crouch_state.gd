class_name CrouchState
extends PlayerMovementState

var speed_state
var crouch_state = 3.0

@onready var spherecast = %ShapeCast3D
@export var animator : AnimationPlayer

func enter(_previous_state):
	animator.play("player_state/crouch_state")

func physics_update(delta):
	player.update_gravity(delta)
	if player.item.Scoped:
		speed_state = crouch_state / 2
	else:
		speed_state = crouch_state
	player.update_input(speed_state, ACCELERATION, DECCELERATION)
	player.update_velocity()
	if Input.is_action_just_released("left_ctrl"):
		uncrouch(delta)
	
func uncrouch(delta):
	if !spherecast.is_colliding() and !Input.is_action_pressed("left_ctrl"):
		animator.play_backwards("player_state/crouch_state")
		if animator.current_animation == "player_state/crouch_state":
			await animator.animation_finished
		transition.emit("Idle")
	elif spherecast.is_colliding():
		await get_tree().create_timer(0.1).timeout
		uncrouch(delta)
