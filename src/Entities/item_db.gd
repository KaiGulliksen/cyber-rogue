extends Node

enum ItemName {
	STIMPAK,
	# Future items:
	# GRENADE,
	# ARMOR,
	# etc.
}

const items = {
	ItemName.STIMPAK: preload("res://src/Assets/Definitions/Entities/Items/stimpak_definition.tres"),
}

# Optional: Helper function for random loot
func get_random_item(rng: RandomNumberGenerator) -> EntityDefinition:
	var item_keys = items.keys()
	return items[item_keys[rng.randi() % item_keys.size()]]
