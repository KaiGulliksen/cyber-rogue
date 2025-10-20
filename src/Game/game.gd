class_name Game
extends Node2D

signal player_created(player)

const player_definition: EntityDefinition = preload("res://src/Assets/Definitions/Entities/Actors/entity_definition_player.tres")
const tile_size = 16

enum GameState { HUB, DUNGEON }

var current_state: GameState = GameState.DUNGEON

@onready var player: Entity
@onready var input_handler: InputHandler = $InputHandler
@onready var hub: Hub = $Hub
@onready var maintenance_map: MaintenanceMap = $MaintenanceMap
@onready var camera: Camera2D = $Camera2D


func _ready() -> void:
	player = Entity.new(null, Vector2i.ZERO, player_definition)
	player_created.emit(player)
	remove_child(camera)
	player.add_child(camera)
	
	# Hide hub initially
	hub.visible = false
	
	# Start in dungeon
	maintenance_map.generate(player)
	update_fov(player.grid_position)
	MessageLog.send_message.bind(
		"You wake up...",
		GameColors.WELCOME_TEXT
	).call_deferred()
	camera.make_current.call_deferred()


func _physics_process(_delta: float) -> void:
	var action: Action = await input_handler.get_action(player)
	if action:
		var previous_player_position: Vector2i = player.grid_position
		if action.perform():
			_handle_enemy_turns()
			update_fov(player.grid_position)


func _handle_enemy_turns() -> void:
	for entity in get_map_data().entities:
		if entity.is_alive() and entity != player:
			entity.ai_component.perform()


func get_map_data() -> MapData:
	if current_state == GameState.HUB:
		return hub.map_data
	else:
		return maintenance_map.map_data


func update_fov(player_position: Vector2i) -> void:
	if current_state == GameState.HUB:
		# In hub, make everything visible
		for entity in get_map_data().entities:
			entity.visible = true
	else:
		# In dungeon, use FOV
		maintenance_map.update_fov(player_position)


func transition_to_hub() -> void:
	MessageLog.send_message(
		"You enter the hub...",
		GameColors.WELCOME_TEXT
	)
	
	# Remove player from dungeon
	player.get_parent().remove_child(player)
	
	# Hide dungeon, show hub
	maintenance_map.visible = false
	hub.visible = true
	
	# Generate hub
	hub.generate(player)
	
	# Update state
	current_state = GameState.HUB
	
	# Update FOV for new location
	update_fov(player.grid_position)
	camera.make_current.call_deferred()
