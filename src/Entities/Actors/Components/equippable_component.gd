class_name EquippableComponent
extends Component

enum EquipmentType { WEAPON, ARMOR }

var equipment_type: EquipmentType
var strength_bonus: int
var dexterity_bonus: int
var armor_bonus: int
var evasion_bonus: int


func _init(definition: EquippableComponentDefinition) -> void:
	equipment_type = definition.equipment_type
	strength_bonus = definition.strength_bonus
	dexterity_bonus = definition.dexterity_bonus
	armor_bonus = definition.armor_bonus
	evasion_bonus = definition.evasion_bonus
