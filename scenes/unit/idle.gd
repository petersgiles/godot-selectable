extends UnitState
class_name Idle

func enter(_previous_state_path: String, _data := {}) -> void:
	unit.velocity.x = 0.0
	unit.velocity.z = 0.0
	unit.animation_player.play("medium/Idle_A")


func physics_update(delta: float) -> void:
	unit.apply_gravity(delta)
	unit.apply_idle_damping(delta)
	unit.move_with_current_velocity()
