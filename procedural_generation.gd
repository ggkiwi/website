
## Path Iterator
func start_path() -> void:
	for i : int in range(floor_margin_x, room_size.x - floor_margin_x):
		for j : int in range(floor_margin_y, room_size.y - floor_margin_y):
			var input_vec : Vector2i = Vector2i(i, j)
			path_fill(input_vec)

enum Direction {LEFT, UP,  DOWN, RIGHT,}
var acceptable_direction_array : Array = []

func loop_prevented(input: Vector2i) -> bool:
	var count: int = 0
	# Check 4 directions, if count 2 is found return false
	for i : Vector2i in Help.direction:
		if floors.get_cell_tile_data(input + i) != null: count += 1
		if count >= 2: return false
	return true

## Flood Fill - Perfect Maze
func path_fill(input_vec: Vector2i) -> void:
	var path_array: Array = []
	var prev_direction: int = -1
	
	# 1. Must be an empty tile
	if floors.get_cell_tile_data(input_vec) != null: return
	if not loop_prevented(input_vec): return
	# 2. Must not be bordering a room
	if border_array.has(input_vec): return
	# 3. No 4 tile corners
	if not advanced_corner_check(input_vec, true): return
	
	# Start Point
	terraform(floors, [input_vec], current_floor.biome, TileType.FLOOR)
	path_array.append(input_vec)
	
	# Path Iteration
	# Start from bottom of the stack
	while not path_array.is_empty():
		acceptable_direction_array = []
		var chosen_vec: Vector2i = path_array[-1]
		
		# Compile Available directions
		for i : int in Direction.values():
			direction_check(chosen_vec, i)
		
		# No directions available, go to next iteration 
		if acceptable_direction_array.is_empty():
			path_array.pop_back()
			continue # Goes to next while iteration
		
		# No previous direction, randomize direction
		if prev_direction == -1:
			prev_direction = Help.pick_random(acceptable_direction_array)
		else:
			var chance_roll : int = Help.rng.randi_range(1,100)
			if acceptable_direction_array.has(prev_direction) and chance_roll > 65: # from 40 to 50 changes a bunch (unsolvable at 50?
				pass # Continues to stay as previous direction
			else:
				prev_direction = Help.pick_random(acceptable_direction_array)
		
		match prev_direction:
			Direction.LEFT: chosen_vec = chosen_vec + Vector2i.LEFT
			Direction.UP: chosen_vec = chosen_vec + Vector2i.UP
			Direction.RIGHT: chosen_vec = chosen_vec + Vector2i.RIGHT
			Direction.DOWN: chosen_vec = chosen_vec + Vector2i.DOWN
		
		
		terraform(floors, [chosen_vec], current_floor.biome, TileType.FLOOR)
		path_array.append(chosen_vec)
	
	cell_walls = walls.get_used_cells()
