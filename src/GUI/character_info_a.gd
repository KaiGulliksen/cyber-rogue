extends VBoxContainer


var _player: Entity


@onready var armor_label: Label = $ArmorLabel
@onready var evasion_label: Label = $EvasionLabel


func initialize(player: Entity) -> void:
	_player = player
	update_labels()
	

func update_labels() -> void:
	armor_label.text = "AR: %d" % _player.fighter_component.armor
	evasion_label.text = "EV: %d" % _player.fighter_component.evasion
