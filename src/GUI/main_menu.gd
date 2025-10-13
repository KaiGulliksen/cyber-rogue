class_name MainMenu
extends Control


@onready var new_game_button: Button = $%NewGameButton


func _ready():
	new_game_button.grab_focus()


func _on_new_game_button_pressed() -> void:
	get_tree().change_scene_to_file("res://src/Game/game.tscn")


func _on_load_game_button_pressed() -> void:
	pass # Replace with function body.


func _on_options_button_pressed() -> void:
	pass # Replace with function body.


func _on_quit_game_button_pressed() -> void:
	get_tree().quit()
