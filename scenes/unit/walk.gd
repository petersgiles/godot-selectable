extends UnitState
class_name Walk

func enter(_previous_state_path: String, data := {}) -> void:
	if data.has("target_position"):
		unit.set_move_target(data["target_position"])
	unit.velocity.x = 0.0
	unit.velocity.z = 0.0
	unit.animation_player.play("medium/Walking_A")


func physics_update(delta: float) -> void:
	unit.apply_gravity(delta)

	var move_target := unit.get_move_target()
	var to_target := Vector3(move_target.x - unit.global_position.x, 0.0, move_target.z - unit.global_position.z)
	if to_target.length() <= unit.stop_distance:
		unit.velocity.x = 0.0
		unit.velocity.z = 0.0
		finished.emit(IDLE)
		unit.move_with_current_velocity()
		return

	var direction := to_target.normalized()
	unit.velocity.x = direction.x * unit.move_speed
	unit.velocity.z = direction.z * unit.move_speed
	unit.face_towards(unit.global_position + direction)
	unit.move_with_current_velocity()
