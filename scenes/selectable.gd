extends Node
class_name Selectable

signal selected_changed(is_selected: bool)

@export var selectable_group: String = "units"

var is_selected: bool = false
var _selection_bus: Node


func _ready() -> void:
	add_to_group("selectable")
	if not selectable_group.is_empty():
		add_to_group(_group_tag(selectable_group))

	_selection_bus = get_tree().get_first_node_in_group("selection_bus")
	if _selection_bus == null:
		return

	_selection_bus.selection_set_requested.connect(_on_selection_set_requested)
	_selection_bus.selection_toggle_requested.connect(_on_selection_toggle_requested)
	_selection_bus.selection_clear_requested.connect(_on_selection_clear_requested)
	_selection_bus.selection_group_requested.connect(_on_selection_group_requested)


func _exit_tree() -> void:
	if _selection_bus == null:
		return

	if _selection_bus.selection_set_requested.is_connected(_on_selection_set_requested):
		_selection_bus.selection_set_requested.disconnect(_on_selection_set_requested)
	if _selection_bus.selection_toggle_requested.is_connected(_on_selection_toggle_requested):
		_selection_bus.selection_toggle_requested.disconnect(_on_selection_toggle_requested)
	if _selection_bus.selection_clear_requested.is_connected(_on_selection_clear_requested):
		_selection_bus.selection_clear_requested.disconnect(_on_selection_clear_requested)
	if _selection_bus.selection_group_requested.is_connected(_on_selection_group_requested):
		_selection_bus.selection_group_requested.disconnect(_on_selection_group_requested)


func set_selected(value: bool) -> void:
	if is_selected == value:
		return

	is_selected = value
	selected_changed.emit(is_selected)


func toggle_selected() -> void:
	set_selected(not is_selected)


func is_in_selectable_group(group_name: String) -> bool:
	if group_name.is_empty():
		return false
	return selectable_group == group_name or is_in_group(_group_tag(group_name))


func _group_tag(group_name: String) -> String:
	return "selectable_group_%s" % group_name


func _on_selection_set_requested(target_selectable: Node) -> void:
	set_selected(target_selectable == self)


func _on_selection_toggle_requested(target_selectable: Node) -> void:
	if target_selectable == self:
		toggle_selected()
	else:
		set_selected(false)


func _on_selection_clear_requested() -> void:
	set_selected(false)


func _on_selection_group_requested(group_name: String) -> void:
	set_selected(is_in_selectable_group(group_name))
