class_name Entity
extends Sprite2D


enum AIType {NONE, HOSTILE}
enum EntityType {CORPSE, ITEM, ACTOR, PORTAL}


var grid_position: Vector2i:
	set(value):
		grid_position = value
		position = Grid.grid_to_world(grid_position)


var _definition: EntityDefinition
var entity_name: String
var blocks_movement: bool
var type: EntityType:
	set(value):
		type = value
		z_index = type
var map_data: MapData


var fighter_component: FighterComponent
var ai_component: BaseAIComponent
var consumable_component: ConsumableComponent
var equippable_component: EquippableComponent
var inventory_component: InventoryComponent


func _init(map_data: MapData, start_position: Vector2i, entity_definition: EntityDefinition) -> void:
	centered = false
	grid_position = start_position
	self.map_data = map_data
	set_entity_type(entity_definition)


func set_entity_type(entity_definition: EntityDefinition) -> void:
	_definition = entity_definition
	type = _definition.type
	blocks_movement = _definition.is_blocking_movement
	entity_name = _definition.name
	texture = entity_definition.texture
	modulate = entity_definition.color
	
	match entity_definition.ai_type:
		AIType.HOSTILE:
			ai_component = HostileEnemyAIComponent.new()
			add_child(ai_component)
	
	if entity_definition.fighter_definition:
		fighter_component = FighterComponent.new(entity_definition.fighter_definition)
		add_child(fighter_component)
	
	var item_definition: ItemComponentDefinition = entity_definition.item_definition	
	if item_definition:
		if item_definition is ConsumableComponentDefinition:
			_handle_consumable(item_definition)
		else:
			equippable_component = EquippableComponent.new(item_definition)
			
	if entity_definition.inventory_capacity > 0:
		inventory_component = InventoryComponent.new()
		inventory_component.capacity = entity_definition.inventory_capacity
		add_child(inventory_component)


func move(move_offset: Vector2i) -> void:
	map_data.unregister_blocking_entity(self)
	grid_position += move_offset
	map_data.register_blocking_entity(self)


func is_blocking_movement() -> bool:
	return blocks_movement


func get_entity_name() -> String:
	return entity_name


func get_entity_type() -> int:
	return _definition.type


func is_alive() -> bool:
	return ai_component != null


func _handle_consumable(consumable_definition: ConsumableComponentDefinition) -> void:
	if consumable_definition is HealingConsumableComponentDefinition:
		consumable_component = HealingConsumableComponent.new(consumable_definition)

	if consumable_component:
		add_child(consumable_component)
	consumable_component.entity = self
