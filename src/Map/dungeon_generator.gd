class_name DungeonGenerator
extends Node


@export_category("Map Dimensions")
@export var map_width: int = 90
@export var map_height: int = 90

@export_category("BSP Configuration")
@export var min_room_size: int = 6
@export var max_room_size: int = 12
@export var min_partition_size: int = 10
@export var max_depth: int = 5
@export var corridor_width: int = 3

@export_category("Dungeon Progression")
@export var max_floors: int = 4


var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()


class BSPNode:
	var rect: Rect2i
	var left: BSPNode = null
	var right: BSPNode = null
	var room: Rect2i = Rect2i()
	var is_leaf: bool = true
	
	func _init(p_rect: Rect2i):
		rect = p_rect


func _split_partition(node: BSPNode, depth: int, max_depth: int, min_size: int, rng: RandomNumberGenerator) -> void:
	if depth >= max_depth:
		return
	
	# Calculate minimum size needed for a room + walls
	var min_size_for_room = min_room_size + 2
	
	# Check if partition is large enough to split AND fit rooms in both children
	if node.rect.size.x < min_size_for_room * 2 and node.rect.size.y < min_size_for_room * 2:
		# Can't split while maintaining room requirements
		return
	
	# Decide split direction based on partition shape and room requirements
	var split_horizontally: bool
	var can_split_horizontal = node.rect.size.y >= min_size_for_room * 2
	var can_split_vertical = node.rect.size.x >= min_size_for_room * 2
	
	if not can_split_horizontal and not can_split_vertical:
		return  # Can't split in either direction
	elif can_split_horizontal and not can_split_vertical:
		split_horizontally = true
	elif can_split_vertical and not can_split_horizontal:
		split_horizontally = false
	else:
		# Both directions possible, choose based on aspect ratio with some randomness
		if node.rect.size.x > node.rect.size.y * 1.25:
			split_horizontally = false  # Wide partition, split vertically
		elif node.rect.size.y > node.rect.size.x * 1.25:
			split_horizontally = true  # Tall partition, split horizontally
		else:
			split_horizontally = rng.randf() > 0.5  # Similar aspect ratio, random
	
	# Calculate split position ensuring both sides can hold rooms
	if split_horizontally:
		var min_split = min_size_for_room
		var max_split = node.rect.size.y - min_size_for_room
		if max_split <= min_split:
			return
		var split_pos = rng.randi_range(min_split, max_split)
		
		node.left = BSPNode.new(Rect2i(
			node.rect.position.x,
			node.rect.position.y,
			node.rect.size.x,
			split_pos
		))
		
		node.right = BSPNode.new(Rect2i(
			node.rect.position.x,
			node.rect.position.y + split_pos,
			node.rect.size.x,
			node.rect.size.y - split_pos
		))
	else:
		var min_split = min_size_for_room
		var max_split = node.rect.size.x - min_size_for_room
		if max_split <= min_split:
			return
		var split_pos = rng.randi_range(min_split, max_split)
		
		node.left = BSPNode.new(Rect2i(
			node.rect.position.x,
			node.rect.position.y,
			split_pos,
			node.rect.size.y
		))
		
		node.right = BSPNode.new(Rect2i(
			node.rect.position.x + split_pos,
			node.rect.position.y,
			node.rect.size.x - split_pos,
			node.rect.size.y
		))
	
	node.is_leaf = false
	
	# Recursively split children
	_split_partition(node.left, depth + 1, max_depth, min_size, rng)
	_split_partition(node.right, depth + 1, max_depth, min_size, rng)


func _create_rooms(node: BSPNode, min_room_size: int, max_room_size: int, rng: RandomNumberGenerator) -> void:
	if node.is_leaf:
		# Calculate the maximum room size that can fit in this partition
		var available_width = node.rect.size.x - 2  # Leave 1 tile margin on each side
		var available_height = node.rect.size.y - 2
		
		if available_width < min_room_size or available_height < min_room_size:
			print("ERROR: Partition too small for minimum room: ", node.rect, " (need ", min_room_size, "x", min_room_size, ")")
			# This should never happen if splitting logic is correct
			# Create the smallest possible room as fallback
			var fallback_width = max(3, available_width)
			var fallback_height = max(3, available_height)
			node.room = Rect2i(
				node.rect.position.x + 1,
				node.rect.position.y + 1,
				fallback_width,
				fallback_height
			)
			print("  Created fallback room: ", node.room)
			return
		
		# Calculate room dimensions
		var max_width = min(max_room_size, available_width)
		var max_height = min(max_room_size, available_height)
		
		var room_width = rng.randi_range(min_room_size, max_width)
		var room_height = rng.randi_range(min_room_size, max_height)
		
		# Calculate position within partition (with margins)
		var max_x_offset = available_width - room_width
		var max_y_offset = available_height - room_height
		
		var x_offset = 0 if max_x_offset <= 0 else rng.randi_range(0, max_x_offset)
		var y_offset = 0 if max_y_offset <= 0 else rng.randi_range(0, max_y_offset)
		
		var room_x = node.rect.position.x + 1 + x_offset
		var room_y = node.rect.position.y + 1 + y_offset
		
		node.room = Rect2i(room_x, room_y, room_width, room_height)
		print("Created room: ", node.room, " in partition: ", node.rect)
	else:
		# Recursively create rooms in children
		if node.left:
			_create_rooms(node.left, min_room_size, max_room_size, rng)
		else:
			print("WARNING: Non-leaf node has no left child")
		if node.right:
			_create_rooms(node.right, min_room_size, max_room_size, rng)
		else:
			print("WARNING: Non-leaf node has no right child")


func _get_room_center(room: Rect2i) -> Vector2i:
	return Vector2i(
		room.position.x + room.size.x / 2,
		room.position.y + room.size.y / 2
	)


func _create_corridor(dungeon: MapData, start: Vector2i, end: Vector2i, width: int, rng: RandomNumberGenerator) -> void:
	print("    Creating corridor from ", start, " to ", end, " (width: ", width, ")")
	
	# Check if points are already aligned (same X or same Y)
	var aligned_horizontal = (start.y == end.y)
	var aligned_vertical = (start.x == end.x)
	
	if aligned_horizontal:
		# Can make a straight horizontal corridor
		print("      Straight: horizontal (aligned)")
		var tiles_carved = _carve_horizontal_corridor(dungeon, start.x, end.x, start.y, width)
		print("      Carved ", tiles_carved, " tiles")
	elif aligned_vertical:
		# Can make a straight vertical corridor
		print("      Straight: vertical (aligned)")
		var tiles_carved = _carve_vertical_corridor(dungeon, start.y, end.y, start.x, width)
		print("      Carved ", tiles_carved, " tiles")
	else:
		# Not aligned - must use L-shaped corridor
		var horizontal_first = rng.randf() > 0.5
		
		if horizontal_first:
			print("      L-shape: horizontal then vertical")
			# Horizontal then vertical
			var tiles_carved = _carve_horizontal_corridor(dungeon, start.x, end.x, start.y, width)
			print("      Horizontal: carved ", tiles_carved, " tiles")
			tiles_carved = _carve_vertical_corridor(dungeon, start.y, end.y, end.x, width)
			print("      Vertical: carved ", tiles_carved, " tiles")
		else:
			print("      L-shape: vertical then horizontal")
			# Vertical then horizontal
			var tiles_carved = _carve_vertical_corridor(dungeon, start.y, end.y, start.x, width)
			print("      Vertical: carved ", tiles_carved, " tiles")
			tiles_carved = _carve_horizontal_corridor(dungeon, start.x, end.x, end.y, width)
			print("      Horizontal: carved ", tiles_carved, " tiles")


func _carve_horizontal_corridor(dungeon: MapData, x1: int, x2: int, y: int, width: int) -> int:
	var start_x = min(x1, x2)
	var end_x = max(x1, x2)
	var half_width = width / 2
	var tiles_carved = 0
	
	for x in range(start_x, end_x + 1):
		for dy in range(-half_width, half_width + 1):
			var tile_y = y + dy
			if _carve_tile(dungeon, x, tile_y):
				tiles_carved += 1
	
	return tiles_carved


func _carve_vertical_corridor(dungeon: MapData, y1: int, y2: int, x: int, width: int) -> int:
	var start_y = min(y1, y2)
	var end_y = max(y1, y2)
	var half_width = width / 2
	var tiles_carved = 0
	
	for y in range(start_y, end_y + 1):
		for dx in range(-half_width, half_width + 1):
			var tile_x = x + dx
			if _carve_tile(dungeon, tile_x, y):
				tiles_carved += 1
	
	return tiles_carved


func _carve_tile(dungeon: MapData, x: int, y: int) -> bool:
	var tile_position = Vector2i(x, y)
	if not dungeon.is_in_bounds(tile_position):
		return false
		
	var tile: Tile = dungeon.get_tile(tile_position)
	if tile:
		if not tile.is_walkable():
			tile.set_tile_type(TileDB.TileName.FLOOR1)
			return true
	return false


func _carve_room(dungeon: MapData, room: Rect2i) -> void:
	for y in range(room.position.y, room.position.y + room.size.y):
		for x in range(room.position.x, room.position.x + room.size.x):
			_carve_tile(dungeon, x, y)


func _connect_rooms(dungeon: MapData, node: BSPNode, rng: RandomNumberGenerator, depth: int) -> void:
	if node == null or node.is_leaf:
		return
	
	# Connect children first (recursively) - this ensures deepest pairs connect first
	if node.left:
		_connect_rooms(dungeon, node.left, rng, depth + 1)
	if node.right:
		_connect_rooms(dungeon, node.right, rng, depth + 1)
	
	# Now connect this partition's left and right sides
	# This happens AFTER children are connected (bottom-up)
	if node.left == null or node.right == null:
		print("WARNING at depth ", depth, ": Partition has null child")
		return
	
	# Get representative rooms from each side
	var left_room = _get_representative_room(node.left, rng)
	var right_room = _get_representative_room(node.right, rng)
	
	# Ensure both rooms are valid
	if left_room == Rect2i() or right_room == Rect2i():
		print("WARNING at depth ", depth, ": Could not find valid rooms to connect")
		return
	
	# Connect these two rooms
	var left_center = _get_room_center(left_room)
	var right_center = _get_room_center(right_room)
	
	print("Depth ", depth, ": Connecting ", left_center, " -> ", right_center)
	_create_corridor(dungeon, left_center, right_center, corridor_width, rng)


func _get_representative_room(node: BSPNode, rng: RandomNumberGenerator) -> Rect2i:
	"""Get a representative room from this subtree, preferring rooms closest to the partition boundary"""
	if node == null:
		return Rect2i()
	
	if node.is_leaf:
		return node.room
	
	# For non-leaf nodes, get a room from each child and pick one
	var left_room = Rect2i()
	var right_room = Rect2i()
	
	if node.left:
		left_room = _get_representative_room(node.left, rng)
	if node.right:
		right_room = _get_representative_room(node.right, rng)
	
	# Return a valid room, preferring to have options
	if left_room != Rect2i() and right_room != Rect2i():
		# Both valid, pick randomly
		return left_room if rng.randf() > 0.5 else right_room
	elif left_room != Rect2i():
		return left_room
	elif right_room != Rect2i():
		return right_room
	else:
		return Rect2i()


func _get_all_leaf_rooms(node: BSPNode) -> Array[Rect2i]:
	var rooms: Array[Rect2i] = []
	if node == null:
		return rooms
	
	if node.is_leaf:
		if node.room != Rect2i():
			rooms.append(node.room)
	else:
		rooms.append_array(_get_all_leaf_rooms(node.left))
		rooms.append_array(_get_all_leaf_rooms(node.right))
	
	return rooms


func _get_all_rooms(node: BSPNode, rooms: Array[Rect2i]) -> void:
	if node == null:
		return
	
	if node.is_leaf and node.room != Rect2i():
		rooms.append(node.room)
	else:
		_get_all_rooms(node.left, rooms)
		_get_all_rooms(node.right, rooms)


func generate_dungeon(player: Entity, current_floor: int) -> MapData:
	var dungeon := MapData.new(map_width, map_height, player)
	dungeon.current_floor = current_floor
	dungeon.entities.append(player)
	
	print("\n=== STARTING DUNGEON GENERATION ===")
	
	# Create BSP tree
	var root_rect = Rect2i(1, 1, map_width - 2, map_height - 2)
	var root = BSPNode.new(root_rect)
	
	# Split the space
	print("Splitting space...")
	_split_partition(root, 0, max_depth, min_partition_size, _rng)
	
	# Count leaf nodes
	var leaf_count = _count_leaf_nodes(root)
	print("Created ", leaf_count, " leaf partitions")
	
	# Create rooms in leaf nodes
	print("\nCreating rooms...")
	_create_rooms(root, min_room_size, max_room_size, _rng)
	
	# Get all rooms
	var all_rooms: Array[Rect2i] = []
	_get_all_rooms(root, all_rooms)
	print("Successfully created ", all_rooms.size(), " rooms")
	
	if all_rooms.size() < leaf_count:
		print("ERROR: ", leaf_count - all_rooms.size(), " partitions did not get rooms!")
		print("This will cause connectivity issues!")
	
	# Validate the tree before connecting
	print("\nValidating BSP tree...")
	var validation_errors = _validate_tree(root)
	if validation_errors > 0:
		print("ERROR: Found ", validation_errors, " validation errors in BSP tree!")
	else:
		print("BSP tree validation passed")
	
	# Carve rooms
	print("\nCarving rooms into map...")
	for room in all_rooms:
		_carve_room(dungeon, room)
	
	# Place player in first room (before connecting so connectivity check works)
	if not all_rooms.is_empty():
		var first_room = all_rooms[0]
		player.grid_position = _get_room_center(first_room)
		print("\nPlayer placed at: ", player.grid_position)
	else:
		player.grid_position = Vector2i(map_width / 2, map_height / 2)
	
	player.map_data = dungeon
	
	# Connect rooms with corridors (bottom-up: deepest pairs first)
	print("\nConnecting rooms with corridors (deepest to shallowest)...")
	_connect_rooms(dungeon, root, _rng, 0)
	print("Corridor connections complete")
	
	# Verify connectivity
	print("\nVerifying dungeon connectivity...")
	var unreachable_rooms = _check_connectivity(dungeon, all_rooms, player.grid_position)
	if unreachable_rooms > 0:
		print("ERROR: ", unreachable_rooms, " rooms are unreachable from player start!")
	else:
		print("SUCCESS: All rooms are connected and reachable!")
	
	# Place downstairs in furthest room
	var furthest_room = _get_furthest_room(all_rooms, player.grid_position)
	if furthest_room != Rect2i():
		var stair_location = _get_room_center(furthest_room)
		dungeon.down_stair_location = stair_location
		
		if current_floor < max_floors:
			var down_tile: Tile = dungeon.get_tile(stair_location)
			if down_tile:
				down_tile.set_tile_type(TileDB.TileName.DOWNSTAIR)
	
	dungeon.setup_pathfinding()
	print("=== DUNGEON GENERATION COMPLETE ===\n")
	return dungeon


func _count_leaf_nodes(node: BSPNode) -> int:
	if node == null:
		return 0
	if node.is_leaf:
		return 1
	return _count_leaf_nodes(node.left) + _count_leaf_nodes(node.right)


func _validate_tree(node: BSPNode) -> int:
	"""Validate the BSP tree structure and return the number of errors found"""
	var errors = 0
	
	if node == null:
		return 0
	
	if node.is_leaf:
		# Leaf nodes must have rooms
		if node.room == Rect2i():
			print("  ERROR: Leaf node has no room at partition: ", node.rect)
			errors += 1
	else:
		# Non-leaf nodes must have both children
		if node.left == null:
			print("  ERROR: Non-leaf node missing left child")
			errors += 1
		if node.right == null:
			print("  ERROR: Non-leaf node missing right child")
			errors += 1
		
		# Recursively validate children
		if node.left:
			errors += _validate_tree(node.left)
		if node.right:
			errors += _validate_tree(node.right)
	
	return errors


func _check_connectivity(dungeon: MapData, rooms: Array[Rect2i], start_pos: Vector2i) -> int:
	"""Check if all room centers are reachable from the start position using flood fill"""
	# Get all room centers
	var room_centers: Array[Vector2i] = []
	for room in rooms:
		room_centers.append(_get_room_center(room))
	
	# Flood fill from start position
	var visited: Dictionary = {}
	var queue: Array[Vector2i] = [start_pos]
	visited[start_pos] = true
	
	var directions = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
	
	while not queue.is_empty():
		var current = queue.pop_front()
		
		for direction in directions:
			var next_pos = current + direction
			
			if visited.has(next_pos):
				continue
			
			if not dungeon.is_in_bounds(next_pos):
				continue
			
			var tile = dungeon.get_tile(next_pos)
			if tile and tile.is_walkable():
				visited[next_pos] = true
				queue.append(next_pos)
	
	# Check which room centers were reached
	var unreachable = 0
	for i in range(room_centers.size()):
		var center = room_centers[i]
		if not visited.has(center):
			print("  ERROR: Room ", i, " at ", center, " is UNREACHABLE")
			unreachable += 1
	
	return unreachable


func _get_furthest_room(rooms: Array[Rect2i], from_pos: Vector2i) -> Rect2i:
	var furthest_room = Rect2i()
	var max_distance = 0.0
	
	for room in rooms:
		var room_center = _get_room_center(room)
		var distance = from_pos.distance_to(room_center)
		if distance > max_distance:
			max_distance = distance
			furthest_room = room
	
	return furthest_room
