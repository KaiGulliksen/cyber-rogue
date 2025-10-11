class_name Hub
extends Node2D

@export var hub_width: int = 74
@export var hub_height: int = 74  
@export var player_spawn_position: Vector2i = Vector2i(35, 20)

var map_data: MapData
var tile_map: Tile

@onready var tile_map_layer: TileMapLayer = $TileMapLayer
@onready var tiles: Node2D = $Tiles
@onready var entities: Node2D = $Entities


func generate(player: Entity) -> void:
	map_data = MapData.new(hub_width, hub_height, player)
	_setup_tiles_from_tilemap()
	
	player.grid_position = player_spawn_position
	player.map_data = map_data
	map_data.entities.append(player)
	entities.add_child(player)
	
	map_data.setup_pathfinding()


func _setup_tiles_from_tilemap() -> void:
	for y in range(hub_height):
		for x in range(hub_width):
			var tile_pos = Vector2i(x, y)
			var tile: Tile = map_data.get_tile(tile_pos)
			
			var atlas_coords = tile_map_layer.get_cell_atlas_coords(tile_pos)
			
			if atlas_coords == Vector2i(-1, -1):
				# No tile - default to wall
				tiles.add_child(tile)
				continue
			
			var tile_data: TileData = tile_map_layer.get_cell_tile_data(tile_pos)
			if tile_data:
				# Read multiple custom data properties
				var is_walkable = tile_data.get_custom_data("is_walkable") if tile_data.has_custom_data("is_walkable") else false
				var is_transparent = tile_data.get_custom_data("is_transparent") if tile_data.has_custom_data("is_transparent") else is_walkable
				
				# Choose tile type based on walkability
				if is_walkable:
					tile.set_tile_type(TileDB.TileName.FLOOR1)
				else:
					tile.set_tile_type(TileDB.TileName.WALL1)
				
				# You could also manually override transparency if you added that custom data
				# tile._definition.is_transparent = is_transparent
			
			tiles.add_child(tile)
