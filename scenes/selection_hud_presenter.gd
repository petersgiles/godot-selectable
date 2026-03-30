extends Node
class_name SelectionHudPresenter

@onready var units: Node = %Units
@onready var top_center_label: Label = %TopCenterLabel

var _connected_selectables: Array = []


func _ready() -> void:
	units.child_entered_tree.connect(_on_units_children_changed)
	units.child_exiting_tree.connect(_on_units_children_changed)
	_refresh_selectable_connections()
	_update_selection_label()


func _exit_tree() -> void:
	if units != null:
		if units.child_entered_tree.is_connected(_on_units_children_changed):
			units.child_entered_tree.disconnect(_on_units_children_changed)
		if units.child_exiting_tree.is_connected(_on_units_children_changed):
			units.child_exiting_tree.disconnect(_on_units_children_changed)

	for selectable in _connected_selectables:
		if is_instance_valid(selectable) and selectable.selected_changed.is_connected(_on_selectable_changed):
			selectable.selected_changed.disconnect(_on_selectable_changed)

	_connected_selectables.clear()


func _on_units_children_changed(_node: Node) -> void:
	_refresh_selectable_connections()
	_update_selection_label()


func _on_selectable_changed(_is_selected: bool) -> void:
	_update_selection_label()


func _refresh_selectable_connections() -> void:
	for selectable in _connected_selectables:
		if is_instance_valid(selectable) and selectable.selected_changed.is_connected(_on_selectable_changed):
			selectable.selected_changed.disconnect(_on_selectable_changed)

	_connected_selectables.clear()
	for unit_node in units.get_children():
		var selectable := unit_node.get_node_or_null("Selectable")
		if selectable == null:
			continue
		selectable.selected_changed.connect(_on_selectable_changed)
		_connected_selectables.append(selectable)


func _update_selection_label() -> void:
	if top_center_label == null:
		return

	var selected_names: PackedStringArray = []
	for unit_node in units.get_children():
		var selectable := unit_node.get_node_or_null("Selectable")
		if selectable != null and selectable.is_selected:
			selected_names.append(unit_node.name)

	if selected_names.is_empty():
		top_center_label.text = "placeholder"
	else:
		top_center_label.text = "selected: %s" % ", ".join(selected_names)
