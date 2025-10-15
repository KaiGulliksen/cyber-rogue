class_name Game
extends Node2D

signal player_created(player)

const player_definition: EntityDefinition = preload("res://src/Assets/Definitions/Entities/Actors/entity_definition_player.tres")
const tile_size = 16

enum GameState { HUB, DUNGEON }

var current_state: GameState = GameState.HUB

@onready var player: Entity
@onready var input_handler: InputHandler = $InputHandler
@onready var hub: Hub = $Hub
@onready var engineering_map: EngineeringMap = $EngineeringMap
@onready var camera: Camera2D = $Camera2D


func _ready() -> void:
	player = Entity.new(null, Vector2i.ZERO, player_definition)
	player_created.emit(player)
	remove_child(camera)
	player.add_child(camera)
	
	# Hide map initially
	#engineering_map.visible = false
	
	# Start in hub
	hub.generate(player)
	#update_fov(player.grid_position)
	MessageLog.send_message.bind(
		"Hello and welcome, adventurer, to the hub!",
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
		return engineering_map.map_data


func update_fov(player_position: Vector2i) -> void:
	if current_state == GameState.HUB:
		# In hub, make everything visible
		for entity in get_map_data().entities:
			entity.visible = true
	else:
		# In dungeon, use FOV
		engineering_map.update_fov(player_position)


func transition_to_dungeon() -> void:
	MessageLog.send_message(
		"You descend into the dungeon...",
		GameColors.WELCOME_TEXT
	)
	
	# Remove player from hub
	player.get_parent().remove_child(player)
	
	# Hide hub, show map
	hub.visible = false
	engineering_map.visible = true
	
	# Generate dungeon
	engineering_map.generate(player)
	
	# Update state
	current_state = GameState.DUNGEON
	
	# Update FOV for new location
	update_fov(player.grid_position)
	camera.make_current.call_deferred()
