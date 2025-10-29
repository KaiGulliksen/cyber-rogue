extends Node2D

@export var dungeon_generator: DungeonGenerator

var tiles: Node2D
var camera: Camera2D
var is_dragging: bool = false
var drag_start: Vector2
var camera_start_position: Vector2

const MIN_ZOOM = 0.1
const MAX_ZOOM = 5.0
const ZOOM_SPEED = 0.1

func _ready() -> void:
	print("=== MAP PREVIEW STARTING ===")
	
	# Create tiles container
	tiles = Node2D.new()
	tiles.name = "Tiles"
	add_child(tiles)
	print("Tiles container created")
	
	# Setup camera
	camera = Camera2D.new()
	camera.zoom = Vector2(0.5, 0.5)  # Zoomed out to see more
	camera.position = Vector2(0, 0)  # Center of a typical 90x90 map
	add_child(camera)
	camera.make_current()
	print("Camera created at position: ", camera.position, " with zoom: ", camera.zoom)
	
	# Check if dungeon_generator is assigned
	if dungeon_generator == null:
		print("WARNING: dungeon_generator export is null, trying to find it...")
		dungeon_generator = get_node_or_null("DungeonGenerator")
		
		if dungeon_generator == null:
			print("ERROR: Could not find DungeonGenerator node!")
			print("Creating a new DungeonGenerator...")
			dungeon_generator = DungeonGenerator.new()
			dungeon_generator.name = "DungeonGenerator"
			add_child(dungeon_generator)
			print("DungeonGenerator created successfully")
		else:
			print("Found DungeonGenerator node!")
	else:
		print("DungeonGenerator found via export: ", dungeon_generator)
	
	# Generate initial map
	call_deferred("generate_map")


func _input(event: InputEvent) -> void:
	# Handle zooming
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom_camera(1.0 + ZOOM_SPEED)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom_camera(1.0 - ZOOM_SPEED)
		
		# Handle panning
		elif event.button_index == MOUSE_BUTTON_MIDDLE or event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				is_dragging = true
				drag_start = event.position
				camera_start_position = camera.position
			else:
				is_dragging = false
	
	# Update pan while dragging
	if event is InputEventMouseMotion and is_dragging:
		var drag_offset = (drag_start - event.position) / camera.zoom.x
		camera.position = camera_start_position + drag_offset


func _zoom_camera(zoom_factor: float) -> void:
	var new_zoom = camera.zoom * zoom_factor
	new_zoom.x = clamp(new_zoom.x, MIN_ZOOM, MAX_ZOOM)
	new_zoom.y = clamp(new_zoom.y, MIN_ZOOM, MAX_ZOOM)
	camera.zoom = new_zoom
	print("Camera zoom: ", camera.zoom)


func generate_map() -> void:
	print("\n=== GENERATING MAP ===")
	
	# Clear existing tiles
	for child in tiles.get_children():
		child.queue_free()
	print("Cleared old tiles")
	
	# Create a temporary player entity for generation
	var player_def = preload("res://src/Assets/Definitions/Entities/Actors/entity_definition_player.tres")
	print("Player definition loaded: ", player_def)
	
	var temp_player = Entity.new(null, Vector2i.ZERO, player_def)
	print("Temporary player created")
	
	# Generate the dungeon
	print("Calling generate_dungeon...")
	var map_data = dungeon_generator.generate_dungeon(temp_player, 1)
	print("Map data created!")
	print("  Map size: ", map_data.width, "x", map_data.height)
	print("  Total tiles: ", map_data.tiles.size())
	
	# Count tiles
	var wall_count = 0
	var floor_count = 0
	
	# Place tiles and make them all visible
	for tile in map_data.tiles:
		if tile.is_walkable():
			floor_count += 1
		else:
			wall_count += 1
		
		tile.visible = true
		tile.is_explored = true
		tiles.add_child(tile)
	
	print("  Wall tiles: ", wall_count)
	print("  Floor tiles: ", floor_count)
	print("  Tiles added to scene: ", tiles.get_child_count())
	
	# Center camera on player spawn
	var player_world_pos = Grid.grid_to_world(temp_player.grid_position)
	camera.position = player_world_pos
	
	print("  Player grid position: ", temp_player.grid_position)
	print("  Player world position: ", player_world_pos)
	print("  Camera position: ", camera.position)
	print("=== MAP GENERATION COMPLETE ===\n")


func _count_floor_tiles(map_data: MapData) -> int:
	var count = 0
	for tile in map_data.tiles:
		if tile.is_walkable():
			count += 1
	return count


func _on_generate_button_pressed() -> void:
	generate_map()
