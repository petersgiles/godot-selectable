extends Node3D

@export var number_of_units: int = 8
@export var spawn_radius: float = 5.0
@export var floor_y: float = 0.0

const UNIT_SCENE: PackedScene = preload("res://scenes/unit.tscn")
@onready var units: Node = %Units
@onready var units_handler: Units = %Units


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Clear previously spawned units to keep scene reloads deterministic.
	for child in units.get_children():
		child.queue_free()

	if number_of_units <= 0:
		units_handler.refresh_selectables()
		return

	var friend_count := int(floor(float(number_of_units) * 0.5))

	for i in range(number_of_units):
		var unit_instance := UNIT_SCENE.instantiate()
		var unit_index := i + 1
		var assigned_group := "friend" if i < friend_count else "foe"
		unit_instance.name = "Unit_%d" % unit_index
		if unit_instance is Unit:
			(unit_instance as Unit).unit_name = "Unit %d" % unit_index
		var selectable := unit_instance.get_node_or_null("Selectable")
		if selectable != null:
			selectable.selectable_group = assigned_group
		units.add_child(unit_instance, true)
		unit_instance.add_to_group(assigned_group)

		if unit_instance is Node3D:
			var unit_3d := unit_instance as Node3D
			var angle := TAU * float(i) / float(number_of_units)
			var circle_pos := Vector3(cos(angle), 0.0, sin(angle)) * spawn_radius
			unit_3d.position = Vector3(circle_pos.x, floor_y, circle_pos.z)
			unit_3d.look_at(unit_3d.position + circle_pos.normalized(), Vector3.UP)
			unit_3d.rotate_y(PI)

	units_handler.refresh_selectables()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
