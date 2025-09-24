class_name Game
extends Node2D

const player_definition: EntityDefinition = preload("res://src/Assets/Definitions/Entities/Actors/entity_definition_player.tres")

@onready var player: Entity
@onready var event_handler: EventHandler = $EventHandler
@onready var entities: Node2D = $Entities


func _ready() -> void:
	var player_start_pos: Vector2i = Grid.world_to_grid(get_viewport_rect().size.floor() / 2)
	player = Entity.new(player_start_pos, player_definition)
	entities.add_child(player)
	var npc := Entity.new(player_start_pos + Vector2i.RIGHT, player_definition)
	npc.modulate = Color.ORANGE_RED
	entities.add_child(npc)
