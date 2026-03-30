extends Node
class_name Units

@onready var top_center_label: Label = %TopCenterLabel

var _selectables: Array = []
var _current_selection_index: int = -1


func _ready() -> void:
	refresh_selectables()


func _unhandled_input(event: InputEvent) -> void:
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

	_update_selection_label()


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
