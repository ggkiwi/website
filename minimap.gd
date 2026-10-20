## Run after player has taken a step
func update_player_minimap() -> void:
	# Room check 
	var current_room_index: int = player_resource.room_check()
	
	# Is in room, open up room
	if current_room_index != -1:
		var chosen_room: Array[Vector2i] = player_resource.dungeon_room_dict["%s" %current_room_index]
		# Room First
		for i : Vector2i in chosen_room: 
			set_mini_map_cell(i)
		
		# Connectors Next
		var chosen_arr : Array = player_resource.connector_array_rooms[current_room_index]
		if not chosen_arr.is_empty(): # Connectors
			for i : Vector2i in player_resource.connector_array_rooms[current_room_index]: 
				set_mini_map_cell(i)
		
	# 2 tile-away vision (fog of war)
	else:
		for i : Vector2i in Data.directions: 
			two_tile_mini_map_setter(player_resource.grid_position + i)

func set_mini_map_cell(input: Vector2i) -> void:
	var atlas_coords: Vector2i = full_mini_map.get_cell_atlas_coords(input)
	mini_map_border.set_cell(input, 2, atlas_coords)
	mini_map_fill.set_cell(input, 3, atlas_coords)

func two_tile_mini_map_setter(input: Vector2i) -> void:
	# Check if it's a tile on the full minimap
	if full_mini_map.get_cell_atlas_coords(input) != Vector2i(-1,-1):
		# Check if it's not filled in the current minimap
		if mini_map_fill.get_cell_atlas_coords(input) == Vector2i(-1,-1): 
			set_mini_map_cell(input)
