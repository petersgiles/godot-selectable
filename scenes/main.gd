extends Node3D

@export var number_of_units: int = 8
@export var spawn_radius: float = 5.0
@export var floor_y: float = 0.0

const UNIT_SCENE: PackedScene = preload("res://scenes/unit.tscn")
@onready var units: Node = %Units
@onready var top_center_label: Label = $HUD/SafeZone/HudColumns/CenterColumn/TopCenterLabel

var _selectables: Array = []
var _current_selection_index: int = -1


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Clear previously spawned units to keep scene reloads deterministic.
	for child in units.get_children():
		child.queue_free()

	if number_of_units <= 0:
		_refresh_selectables()
		_update_selection_label()
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

	_refresh_selectables()
	_update_selection_label()


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		var key_event := event as InputEventKey
		if key_event.pressed and not key_event.echo:
			if key_event.keycode == KEY_1:
				select_all_in_group("friend")
				get_viewport().set_input_as_handled()
				return
			if key_event.keycode == KEY_2:
				select_all_in_group("foe")
				get_viewport().set_input_as_handled()
				return

	if event.is_action_pressed("ui_focus_next"):
		_cycle_single_selection(1)
		get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("ui_focus_prev"):
		_cycle_single_selection(-1)
		get_viewport().set_input_as_handled()


func select_all_in_group(group_name: String) -> void:
	deselect_all()
	for selectable in _selectables:
		if selectable.is_in_selectable_group(group_name):
			selectable.set_selected(true)
	_current_selection_index = -1
	_update_selection_label()


func deselect_all() -> void:
	for selectable in _selectables:
		selectable.set_selected(false)
	_current_selection_index = -1
	_update_selection_label()


func get_selectables_in_group(group_name: String) -> Array:
	var in_group: Array = []
	for selectable in _selectables:
		if selectable.is_in_selectable_group(group_name):
			in_group.append(selectable)
	return in_group


func _refresh_selectables() -> void:
	_selectables.clear()
	for unit_node in units.get_children():
		var selectable := unit_node.get_node_or_null("Selectable")
		if selectable != null:
			_selectables.append(selectable)


func _cycle_single_selection(step: int) -> void:
	if _selectables.is_empty():
		return

	if _current_selection_index == -1:
		_current_selection_index = 0 if step > 0 else _selectables.size() - 1
	else:
		_current_selection_index = posmod(_current_selection_index + step, _selectables.size())

	for i in range(_selectables.size()):
		_selectables[i].set_selected(i == _current_selection_index)

	_update_selection_label()


func _update_selection_label() -> void:
	if top_center_label == null:
		return

	if _current_selection_index >= 0 and _current_selection_index < _selectables.size():
		var selected_owner: Node = _selectables[_current_selection_index].get_parent()
		top_center_label.text = "selected: %s" % selected_owner.name
		return

	var selected_names: PackedStringArray = []
	for selectable in _selectables:
		if selectable.is_selected:
			var selected_parent: Node = selectable.get_parent()
			selected_names.append(selected_parent.name)

	if selected_names.is_empty():
		top_center_label.text = "placeholder"
	else:
		top_center_label.text = "selected: %s" % ", ".join(selected_names)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
