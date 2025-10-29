extends Node

enum ItemName {
	STIMPAK,
	CROWBAR,
	LEATHERJACKET,
	# ARMOR,
	# etc.
}

const items = {
	ItemName.STIMPAK: preload("res://src/Assets/Definitions/Entities/Items/Consumables/stimpak_definition.tres"),
	ItemName.CROWBAR: preload("res://src/Assets/Definitions/Entities/Items/Weapons/crowbar_definition.tres"),
	ItemName.LEATHERJACKET: preload("res://src/Assets/Definitions/Entities/Items/Armor/leather_jacket_definition.tres"),
}
