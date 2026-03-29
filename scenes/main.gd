extends Node3D

@export var number_of_units: int = 8
@export var spawn_radius: float = 5.0
@export var floor_y: float = 0.0

const UNIT_SCENE: PackedScene = preload("res://scenes/unit.tscn")
@onready var units: Node = %Units


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Clear previously spawned units to keep scene reloads deterministic.
	for child in units.get_children():
		child.queue_free()

	if number_of_units <= 0:
		return

	for i in range(number_of_units):
		var unit_instance := UNIT_SCENE.instantiate()
		units.add_child(unit_instance)

		if unit_instance is Node3D:
			var unit_3d := unit_instance as Node3D
			var angle := TAU * float(i) / float(number_of_units)
			var circle_pos := Vector3(cos(angle), 0.0, sin(angle)) * spawn_radius
			unit_3d.position = Vector3(circle_pos.x, floor_y, circle_pos.z)
			unit_3d.look_at(unit_3d.position + circle_pos.normalized(), Vector3.UP)
			unit_3d.rotate_y(PI)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
