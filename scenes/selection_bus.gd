extends Node
class_name SelectionBus

signal selection_set_requested(target_selectable: Node)
signal selection_toggle_requested(target_selectable: Node)
signal selection_clear_requested()
signal selection_group_requested(group_name: String)


func _ready() -> void:
	add_to_group("selection_bus")


func request_set(target_selectable: Node) -> void:
	selection_set_requested.emit(target_selectable)


func request_toggle(target_selectable: Node) -> void:
	selection_toggle_requested.emit(target_selectable)


func request_clear() -> void:
	selection_clear_requested.emit()


func request_group(group_name: String) -> void:
	selection_group_requested.emit(group_name)
