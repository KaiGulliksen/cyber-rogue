class_name LootTable
extends Resource

@export var entries: Array[LootEntry] = []


func get_items_for_floor(floor: int, rng: RandomNumberGenerator) -> Array[EntityDefinition]:
	var spawned_items: Array[EntityDefinition] = []
	
	for entry in entries:
		# Check if this item can spawn on this floor
		if floor < entry.min_floor or floor > entry.max_floor:
			continue
		
		# Roll for spawn chance
		var roll = rng.randf_range(0, 100)
		if roll <= entry.spawn_chance:
			# Determine quantity
			var quantity = rng.randi_range(entry.min_count, entry.max_count)
			for i in quantity:
				spawned_items.append(entry.item)
	
	return spawned_items


func get_random_item_for_floor(floor: int, rng: RandomNumberGenerator) -> EntityDefinition:
	# Get all valid entries for this floor
	var valid_entries: Array[LootEntry] = []
	
	for entry in entries:
		if floor >= entry.min_floor and floor <= entry.max_floor:
			valid_entries.append(entry)
	
	if valid_entries.is_empty():
		return null
	
	# Shuffle and try each entry's spawn chance
	valid_entries.shuffle()
	for entry in valid_entries:
		var roll = rng.randf_range(0, 100)
		if roll <= entry.spawn_chance:
			return entry.item
	
	# If nothing rolled successfully, return null (no item spawns)
	return null
