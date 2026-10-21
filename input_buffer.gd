var valid_buffer_time: float = 0.15
var buffer : Dictionary = {}
var valid_buffer_actions : Array = [
"move_up_left", "move_up_right", "move_down_left", "move_down_right",
"move_right", "move_left", "move_down", "move_up", "attack",
]

func _physics_process(_delta: float) -> void:
	if is_dead: return
	if player_resource.inventory_open: return
	if player_resource.next_floor_screen_open: return
	if not player_resource.ready_to_move: return
	
	# Buffered Keys
	for action : StringName in valid_buffer_actions:
		if Input.is_action_pressed(action): buffer_push(action)
	
	if not buffer.is_empty():
		if Time.get_ticks_msec() - buffer.values()[0] >  valid_buffer_time:
			buffer.clear()
			return
		if is_attacking: return
		if tween_movement: if tween_movement.is_running(): return
		
		if buffer.keys()[0] == "attack": attack(facing_direction)
		else: single_move_check(Help.move_input_dict[buffer.keys()[0]])
