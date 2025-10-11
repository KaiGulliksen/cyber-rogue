class_name Hub
extends Node2D

var map_data = MapData

@export var hub_width: int = 74
@export var hub_height: int = 74  
@export var player_spawn_position: Vector2i = Vector2i(35, 20)

@onready var tile_map_layer: TileMapLayer = $TileMapLayer
