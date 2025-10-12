class_name ItemSlot
extends PanelContainer

@onready var name_label: Label = $"%ItemNameLabel"
@onready var quantity_label: Label = $"%ItemQuantLabel"
@onready var weight_label: Label = $"%ItemWeightLabel"

var item: Entity
var quantity: int = 1
var slot_index: int = -1

func _ready() -> void:
	# Make sure the slot can receive mouse input
	mouse_filter = Control.MOUSE_FILTER_PASS
