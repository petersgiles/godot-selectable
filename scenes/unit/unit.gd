extends CharacterBody3D
class_name Unit

@export var unit_name: String = "Unit"
@export var move_speed: float = 3.0
@export var stop_distance: float = 0.15
@export var facing_yaw_offset: float = 0.0

var _move_target: Vector3 = Vector3.ZERO

@onready var animation_player: AnimationPlayer = $Visuals/AnimationPlayer
@onready var state_machine: StateMachine = $StateMachine


func command_move_to(target_position: Vector3) -> void:
	_move_target = target_position
	state_machine.transition_to("Walk", {"target_position": target_position})


func command_look_at(target_position: Vector3) -> void:
	_face_towards(target_position)
	state_machine.transition_to("Idle")


func face_towards(target_position: Vector3) -> void:
	_face_towards(target_position)


func set_move_target(target_position: Vector3) -> void:
	_move_target = target_position


func get_move_target() -> Vector3:
	return _move_target


func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta


func apply_idle_damping(delta: float) -> void:
	var damping: float = move_speed * maxf(delta, 0.0001) * 60.0
	velocity.x = move_toward(velocity.x, 0.0, damping)
	velocity.z = move_toward(velocity.z, 0.0, damping)


func move_with_current_velocity() -> void:
	move_and_slide()


func _face_towards(target_position: Vector3) -> void:
	var look_target := Vector3(target_position.x, global_position.y, target_position.z)
	look_at(look_target, Vector3.UP)
	rotate_y(facing_yaw_offset)
