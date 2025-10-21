extends HBoxContainer


var _player: Entity


@onready var armor_label: Label = $CharacterInfoA/ArmorLabel
@onready var evasion_label: Label = $CharacterInfoA/EvasionLabel
@onready var strength_label: Label = $CharacterInfoB/StrengthLabel
@onready var dexterity_label: Label = $CharacterInfoB/DexterityLabel


func initialize(player: Entity) -> void:
	await ready
	_player = player
	update_labels()



func update_labels() -> void:
	armor_label.text = "AR: %d" % _player.fighter_component.armor
	evasion_label.text = "EV: %d" % _player.fighter_component.evasion
	strength_label.text = "STR: %d" % _player.fighter_component.strength
	dexterity_label.text = "DEX: %d" % _player.fighter_component.dexterity
