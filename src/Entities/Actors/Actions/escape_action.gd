class_name EscapeAction
extends Action


func perform() -> bool:
	entity.get_tree().change_scene_to_file("res://src/GUI/main_menu.tscn")
	return false
