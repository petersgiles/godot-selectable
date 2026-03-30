extends Node
class_name Units

@onready var selection_bus = %SelectionBus

var _selectables: Array = []
var _current_selection_index: int = -1


func _ready() -> void:
	refresh_selectables()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT:
			_handle_left_click(mouse_event.position)
			get_viewport().set_input_as_handled()
			return

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


func refresh_selectables() -> void:
	_selectables.clear()
	for unit_node in get_children():
		var selectable := unit_node.get_node_or_null("Selectable")
		if selectable != null:
			_selectables.append(selectable)

	if _current_selection_index >= _selectables.size():
		_current_selection_index = -1


func select_all_in_group(group_name: String) -> void:
	selection_bus.request_group(group_name)
	_current_selection_index = -1


func deselect_all() -> void:
	selection_bus.request_clear()
	_current_selection_index = -1


func get_selectables_in_group(group_name: String) -> Array:
	var in_group: Array = []
	for selectable in _selectables:
		if selectable.is_in_selectable_group(group_name):
			in_group.append(selectable)
	return in_group


func _cycle_single_selection(step: int) -> void:
	if _selectables.is_empty():
		return

	if _current_selection_index == -1:
		_current_selection_index = 0 if step > 0 else _selectables.size() - 1
	else:
		_current_selection_index = posmod(_current_selection_index + step, _selectables.size())

	selection_bus.request_set(_selectables[_current_selection_index])


func _handle_left_click(mouse_position: Vector2) -> void:
	var camera := get_viewport().get_camera_3d()
	if camera == null:
		return

	var ray_origin := camera.project_ray_origin(mouse_position)
	var ray_end := ray_origin + camera.project_ray_normal(mouse_position) * 1000.0
	var query := PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	var result := get_viewport().world_3d.direct_space_state.intersect_ray(query)

	if result.is_empty():
		deselect_all()
		return

	var hit_selectable := _find_selectable_from_collider(result.get("collider"))
	if hit_selectable == null:
		deselect_all()
		return

	_current_selection_index = _selectables.find(hit_selectable)
	selection_bus.request_set(hit_selectable)


func _find_selectable_from_collider(collider: Variant) -> Node:
	if not (collider is Node):
		return null

	var current: Node = collider
	while current != null and current != self:
		var selectable := current.get_node_or_null("Selectable")
		if selectable != null:
			return selectable
		current = current.get_parent()

	return null
