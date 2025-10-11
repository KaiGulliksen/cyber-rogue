class_name Game
extends Node2D

signal player_created(player)

const player_definition: EntityDefinition = preload("res://src/Assets/Definitions/Entities/Actors/entity_definition_player.tres")
const tile_size = 16

@onready var player: Entity
@onready var input_handler: InputHandler = $InputHandler
@onready var hub: Hub = $Hub  # Changed from map to hub
@onready var camera: Camera2D = $Camera2D


func _ready() -> void:
	player = Entity.new(null, Vector2i.ZERO, player_definition)
	player_created.emit(player)
	remove_child(camera)
	player.add_child(camera)
	hub.generate(player)  # Changed from map.generate to hub.generate
	update_fov(player.grid_position)
	MessageLog.send_message.bind(
		"Hello and welcome, adventurer, to the hub!",
		GameColors.WELCOME_TEXT
	).call_deferred()


func _physics_process(_delta: float) -> void:
	var action: Action = input_handler.get_action(player)
	if action:
		var previous_player_position: Vector2i = player.grid_position
		action.perform()
		_handle_enemy_turns()
		update_fov(player.grid_position)


func _handle_enemy_turns() -> void:
	for entity in get_map_data().entities:
		if entity.is_alive() and entity != player:
			entity.ai_component.perform()


func get_map_data() -> MapData:
	return hub.map_data  # Changed from map.map_data


func update_fov(player_position: Vector2i) -> void:
	# You'll need to add a FieldOfView node to the Hub or reuse the Map's one
	# For now, we can create a simple version
	for entity in get_map_data().entities:
		entity.visible = true  # Make all entities visible in the hub for now
