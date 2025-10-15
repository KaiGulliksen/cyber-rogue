extends Node

enum MonsterName {
	ZOMBIE,
	# Future monsters:
	# SKELETON,
	# ORC,
	# etc.
}

const monsters = {
	MonsterName.ZOMBIE: preload("res://src/Assets/Definitions/Entities/Actors/entity_definition_zombie.tres"),
}

# Optional: Helper function to get a random monster for a given danger level
func get_random_monster(rng: RandomNumberGenerator) -> EntityDefinition:
	var monster_keys = monsters.keys()
	return monsters[monster_keys[rng.randi() % monster_keys.size()]]
