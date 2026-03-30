extends CharacterBody3D
class_name Unit

@export var unit_name: String = "Unit"
@export var move_speed: float = 3.0
@export var stop_distance: float = 0.15
@export var facing_yaw_offset: float = 0.0

enum MoveState {
	IDLE,
	WALK,
}

var _move_state: MoveState = MoveState.IDLE
var _move_target: Vector3 = Vector3.ZERO


func command_move_to(target_position: Vector3) -> void:
	_move_target = target_position
	_move_state = MoveState.WALK


func command_look_at(target_position: Vector3) -> void:
	_face_towards(target_position)
	_move_state = MoveState.IDLE
	velocity.x = 0.0
	velocity.z = 0.0


func face_towards(target_position: Vector3) -> void:
	_face_towards(target_position)


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if _move_state == MoveState.WALK:
		var to_target := Vector3(_move_target.x - global_position.x, 0.0, _move_target.z - global_position.z)
		if to_target.length() <= stop_distance:
			_move_state = MoveState.IDLE
			velocity.x = 0.0
			velocity.z = 0.0
		else:
			var direction := to_target.normalized()
			velocity.x = direction.x * move_speed
			velocity.z = direction.z * move_speed
			_face_towards(global_position + direction)
	else:
		velocity.x = move_toward(velocity.x, 0.0, move_speed)
		velocity.z = move_toward(velocity.z, 0.0, move_speed)

	move_and_slide()


func _face_towards(target_position: Vector3) -> void:
	var look_target := Vector3(target_position.x, global_position.y, target_position.z)
	look_at(look_target, Vector3.UP)
	rotate_y(facing_yaw_offset)
