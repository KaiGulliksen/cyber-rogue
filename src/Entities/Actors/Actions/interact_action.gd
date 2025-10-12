class_name InteractAction
extends Action

func perform() -> bool:
	var entity_at_position: Entity = _get_non_actor_entity_at_location(entity.grid_position)
	
	if entity_at_position:
		if entity_at_position.type == Entity.EntityType.PORTAL:
			_use_portal(entity_at_position)
			return true
		else:
			MessageLog.send_message(
				"There's nothing to interact with here.",
				Color.GRAY
			)
			return false
	else:
		MessageLog.send_message(
			"There's nothing to interact with here.",
			Color.GRAY
		)
		return false

func _get_non_actor_entity_at_location(location: Vector2i) -> Entity:
	# Look for entities at this location that aren't actors
	for ent in get_map_data().entities:
		if ent.grid_position == location and ent.type != Entity.EntityType.ACTOR:
			return ent
	return null

func _use_portal(portal: Entity) -> void:
	MessageLog.send_message(
		"You enter the %s..." % portal.entity_name,
		GameColors.WELCOME_TEXT
	)
	
	# Get reference to Game node
	var game_node = entity.get_tree().root.get_node("InterfaceRoot/VBoxContainer/HBoxContainer/SubViewportContainer/SubViewport/Game")
	
	if game_node and game_node.has_method("transition_to_dungeon"):
		game_node.transition_to_dungeon()
