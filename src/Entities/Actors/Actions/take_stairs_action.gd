class_name TakeStairsAction
extends Action


func perform() -> bool:
	var map_data = get_map_data()
	
	if entity.grid_position == map_data.down_stair_location:
		# Check if there's actually a downstair tile here (not a portal)
		var tile: Tile = map_data.get_tile(entity.grid_position)
		if tile and tile.tile_key == TileDB.TileName.DOWNSTAIR:
			SignalBus.player_descended.emit()
			MessageLog.send_message("You descend the staircase.", GameColors.DESCEND)
		else:
			MessageLog.send_message("There are no stairs here.", GameColors.IMPOSSIBLE)
	else:
		MessageLog.send_message("There are no stairs here.", GameColors.IMPOSSIBLE)
	return false
