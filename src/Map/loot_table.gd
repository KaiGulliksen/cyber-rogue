class_name LootTable
extends Resource

@export var entries: Array[LootEntry] = []

# Optional: Global modifiers for this loot table
@export var spawn_rate_multiplier: float = 1.0  # Scale all spawn chances
@export var guaranteed_items: Array[EntityDefinition] = []  # Always spawn these


func get_items_for_floor(floor: int, rng: RandomNumberGenerator) -> Array[EntityDefinition]:
	var spawned_items: Array[EntityDefinition] = []
	
	# Add guaranteed items first
	spawned_items.append_array(guaranteed_items)
	
	for entry in entries:
		# Check if this item can spawn on this floor
		if floor < entry.min_floor or floor > entry.max_floor:
			continue
		
		# Roll for spawn chance (with multiplier)
		var adjusted_chance = entry.spawn_chance * spawn_rate_multiplier
		var roll = rng.randf_range(0, 100)
		if roll <= adjusted_chance:
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
		var adjusted_chance = entry.spawn_chance * spawn_rate_multiplier
		var roll = rng.randf_range(0, 100)
		if roll <= adjusted_chance:
			return entry.item
	
	# If nothing rolled successfully, return null (no item spawns)
	return null


# Get items by rarity
func get_items_by_rarity(rarity: LootEntry.Rarity, floor: int) -> Array[LootEntry]:
	var filtered: Array[LootEntry] = []
	for entry in entries:
		if entry.rarity == rarity and floor >= entry.min_floor and floor <= entry.max_floor:
			filtered.append(entry)
	return filtered


# Get items by tag
func get_items_by_tag(tag: String, floor: int) -> Array[LootEntry]:
	var filtered: Array[LootEntry] = []
	for entry in entries:
		if tag in entry.tags and floor >= entry.min_floor and floor <= entry.max_floor:
			filtered.append(entry)
	return filtered


# Get a guaranteed rare item (useful for boss drops, rewards)
func get_guaranteed_item(rarity: LootEntry.Rarity, floor: int, rng: RandomNumberGenerator) -> EntityDefinition:
	var items = get_items_by_rarity(rarity, floor)
	if items.is_empty():
		return null
	return items[rng.randi() % items.size()].item
