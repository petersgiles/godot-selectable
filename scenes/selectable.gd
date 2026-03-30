extends Node
class_name Selectable

signal selected_changed(is_selected: bool)

@export var selectable_group: String = "units"

var is_selected: bool = false


func _ready() -> void:
	add_to_group("selectable")
	if not selectable_group.is_empty():
		add_to_group(_group_tag(selectable_group))


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
