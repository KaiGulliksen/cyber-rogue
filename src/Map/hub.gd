class_name Hub
extends Node2D

var map_data: MapData

@export var hub_width: int = 74
@export var hub_height: int = 74  
@export var player_spawn_position: Vector2i = Vector2i(35, 20)

@onready var tile_map_layer: TileMapLayer = $TileMapLayer


func setup_area(player: Entity) -> void:
	#initialize_map_data(hub_width, hub_height, player)
	_load_tiles_from_tilemap()
	
	player.grid_position = player_spawn_position
	#add_entity(player)
	
	map_data.setup_pathfinding()


func _load_tiles_from_tilemap() -> void:
	# Read the existing tilemap and create Tile objects in map_data
	for y in range(hub_height):
		for x in range(hub_width):
			var tile_position = Vector2i(x, y)
			var tile_data = tile_map_layer.get_cell_tile_data(tile_position)
			
			# Get the tile from map_data (created as wall by default)
			var map_tile = map_data.get_tile(tile_position)
			if not map_tile:
				continue
			
			if tile_data != null:
				# Check custom data to determine tile type
				var is_walkable = tile_data.get_custom_data("is_walkable")
				var is_portal = tile_data.get_custom_data("is_portal")
				var tile_type = tile_data.get_custom_data("tile_type")
				
				# Set the correct tile type based on tilemap data
				if is_portal:
					map_tile.set_tile_type(TileDB.TileType.PORTAL1)
				elif is_walkable or tile_type == "floor":
					map_tile.set_tile_type(TileDB.TileType.FLOOR1)
				# else keep as wall (default)
			
			# Hide the tilemap tile since we're using our own Tile objects
			# Or you can keep the tilemap visible for visual purposes
