extends BaseInputHandler

const directions = {
	"move_up": Vector2i.UP,
	"move_down": Vector2i.DOWN,
	"move_left": Vector2i.LEFT,
	"move_right": Vector2i.RIGHT,
	"move_up_left": Vector2i.UP + Vector2i.LEFT,
	"move_up_right": Vector2i.UP + Vector2i.RIGHT,
	"move_down_left": Vector2i.DOWN + Vector2i.LEFT,
	"move_down_right": Vector2i.DOWN + Vector2i.RIGHT,
}

const inventory_menu_scene = preload("res://src/GUI/Inventory/Inventory.tscn")


@export var reticle: Reticle


func get_action(player: Entity) -> Action:
	var action: Action = null
	
	for direction in directions:
		if Input.is_action_just_pressed(direction):
			var offset: Vector2i = directions[direction]
			action = BumpAction.new(player, offset.x, offset.y)
	
	if Input.is_action_just_pressed("wait"):
		action = WaitAction.new(player)
	
	if Input.is_action_just_pressed("interact"):
		print("Interacting!")
		action = InteractAction.new(player)
		
	if Input.is_action_just_pressed("inventory"):
		await show_inventory(player)
		
	if Input.is_action_just_pressed("pickup"):
		action = PickupAction.new(player)
		
	if Input.is_action_just_pressed("look"):
		await get_grid_position(player, 0)
		
	if Input.is_action_just_pressed("descend"):
		action = TakeStairsAction.new(player)
	
	if Input.is_action_just_pressed("view_history"):
		get_parent().transition_to(InputHandler.InputHandlers.HISTORY_VIEWER)
	
	if Input.is_action_just_pressed("quit") or Input.is_action_just_pressed("ui_back"):
		action = EscapeAction.new(player)
	
	return action


func show_inventory(player: Entity) -> void:
	var inventory_menu: InventoryMenu = inventory_menu_scene.instantiate()
	var ui_layer = get_viewport()
	ui_layer.add_child(inventory_menu)
	inventory_menu.build("Inventory", player.inventory_component)
	
	# Connect the item_used signal to handle item consumption
	inventory_menu.item_used.connect(_on_inventory_item_used.bind(player))
	
	# Connect the item_dropped signal to handle item dropping
	inventory_menu.item_dropped.connect(_on_inventory_item_dropped.bind(player))
	
	# Transition to dummy handler while menu is open
	get_parent().transition_to(InputHandler.InputHandlers.DUMMY)
	
	# Wait for menu to close
	await inventory_menu.menu_closed
	
	# Small delay to prevent input bleeding through
	await get_tree().process_frame
	
	# Return to main game handler
	get_parent().call_deferred("transition_to", InputHandler.InputHandlers.MAIN_GAME)


func _on_inventory_item_used(item: Entity, player: Entity) -> void:
	# Create the item action and perform it
	var action = ItemAction.new(player, item)
	if action.perform():
		# Remove the item from inventory if it was consumed
		player.inventory_component.items.erase(item)
		# Small delay to ensure message is processed
		await get_tree().create_timer(0.05).timeout
		# Get the game node properly and trigger enemy turns
		var game = player.get_tree().get_root().get_node("InterfaceRoot/VBoxContainer/HBoxContainer/SubViewportContainer/SubViewport/Game")
		if game and game.has_method("_handle_enemy_turns"):
			game._handle_enemy_turns()


func _on_inventory_item_dropped(item: Entity, player: Entity) -> void:
	# Create drop action and perform it
	var action = DropItemAction.new(player, item)
	if action.perform():
		# The drop action already handles removing from inventory
		# Get the game node properly and trigger enemy turns
		var game = player.get_tree().get_root().get_node("InterfaceRoot/VBoxContainer/HBoxContainer/SubViewportContainer/SubViewport/Game")
		if game and game.has_method("_handle_enemy_turns"):
			game._handle_enemy_turns()


func get_grid_position(player: Entity, radius: int) -> Vector2i:
	get_parent().transition_to(InputHandler.InputHandlers.DUMMY)
	var selected_position: Vector2i = await reticle.select_position(player, radius)
	await get_tree().physics_frame
	get_parent().call_deferred("transition_to", InputHandler.InputHandlers.MAIN_GAME)
	return selected_position
