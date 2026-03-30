extends CharacterBody3D
class_name Unit

@export var unit_name: String = "Unit"

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()
