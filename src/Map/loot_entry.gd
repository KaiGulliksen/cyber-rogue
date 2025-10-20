class_name LootEntry
extends Resource

@export var item: EntityDefinition
@export_range(0, 100) var spawn_chance: float = 50.0
@export var min_floor: int = 1
@export var max_floor: int = 999
@export var min_count: int = 1
@export var max_count: int = 1
