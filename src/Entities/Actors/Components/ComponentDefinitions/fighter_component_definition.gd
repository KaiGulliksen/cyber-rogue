class_name FighterComponentDefinition
extends Resource

@export_category("Stats")
@export var max_hp: int
@export var strength: int
@export var dexterity: int
@export var armor: int
@export var evasion: int

@export_category("Visuals")
@export var death_texture: AtlasTexture = preload("res://src/Assets/Resources/default_death_texture.tres")
@export var death_color: Color = Color.DARK_RED
