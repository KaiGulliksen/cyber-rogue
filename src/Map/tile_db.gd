extends Node

enum TileName {
	FLOOR1,
	WALL1,
}

const tile_types = {
	TileName.FLOOR1: preload("res://src/Assets/Definitions/Tiles/tile_definition_floor.tres"),
	TileName.WALL1: preload("res://src/Assets/Definitions/Tiles/tile_definition_wall.tres"),
}
