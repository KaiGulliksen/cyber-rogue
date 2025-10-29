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
