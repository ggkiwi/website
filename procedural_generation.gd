
## Path Iterator
func start_path() -> void:
	for i : int in range(floor_margin_x, room_size.x - floor_margin_x):
		for j : int in range(floor_margin_y, room_size.y - floor_margin_y):
			var input_vec : Vector2i = Vector2i(i, j)
			path_fill_v1(input_vec)

func loop_prevented(input: Vector2i) -> bool:
	var count: int = 0
	# Check 4 directions, if count 2 is found return false
	for i : Vector2i in Help.direction:
		if floors.get_cell_tile_data(input + i) != null: count += 1
		if count >= 2: return false
	return true

## Flood Fill - Perfect Maze
func path_fill_v1(input_vec: Vector2i, prev_direction: Vector2i = Vector2i(0,0)) -> void:
	# 1. Must be an empty tile
	if floors.get_cell_tile_data(input_vec) != null: return
	# 2. Checks 4 spots to prevent loops
	if not loop_prevented(input_vec): return
	# 3. Must not be bordering a room
	if border_array.has(input_vec): return
	# 4. No 4 tile corners
	if not advanced_corner_check(input_vec, true): return
	# 5. Not out of bounds
	if margin_helper_array.has(input_vec): return
	
	# Start Point
	terraform(floors, [input_vec], current_floor.biome, TileType.FLOOR)
	
	var manip_dir_arr: Array = Help.direction.duplicate() # [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
	
	# Has previous direction, slight prefer (35%) going in the same direction
	if prev_direction != Vector2i(0,0) and Help.rng.randi_range(1,100) > 65: # maintain seed
		manip_dir_arr.erase(prev_direction)
		path_fill_v1(input_vec + prev_direction, prev_direction)
	
	for i : int in manip_dir_arr.size():
		var chosen_dir: Vector2i = Help.pick_random(manip_dir_arr) # maintain seed
		manip_dir_arr.erase(chosen_dir)
		path_fill_v1(input_vec + chosen_dir, chosen_dir)

## Trim Dead Ends
func remove_dead_ends(input: Vector2i) -> void:
	var current_floor_arr: Array = floors.get_used_cells()
	
	# Check if input is no longer a floor tile (trimmed via DFS)
	if not current_floor_arr.has(input): return
	
	var exits: int = 0
	var check_next: Vector2i = input
	
	for i : Vector2i in Help.direction:
		if current_floor_arr.has(input + i):
			exits += 1
			if exits > 1: return
			
			check_next += i
	
	terraform(walls, [input], current_floor.biome, TileType.WALLS)
	remove_dead_ends(check_next)

var ccw_direction : Array[Vector2i] = [Vector2i.LEFT, Vector2i.DOWN, Vector2i.RIGHT, Vector2i.UP]
## Maze Solver
func maze_walk_dfs(input: Vector2i) -> void:
	for i : Vector2i in ccw_direction:
		if maze_walk_visited.size() == cell_floors.size(): return
		if not maze_walk_visited.has(input + i) and cell_floors.has(input + i):
			maze_walk_visited.append(input + i)
			tile_dev_margin.set_cell(input + i, 0, Vector2i(0,1), 0)
			maze_walk_dfs(input + i)
