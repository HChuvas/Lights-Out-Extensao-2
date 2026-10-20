function get_random_unocupied_grid_cell(grid){
	var pos_x, pos_y;
	
	while(true){
		pos_x = irandom_range(0, (500 / obj_manager.cell_size) - 1);
		pos_y = irandom_range(0, (400 / obj_manager.cell_size) - 1);
	
		if(mp_grid_get_cell(grid, pos_x, pos_y) == 0){
			// show_debug_message(pos_x);
			// show_debug_message(pos_y);
			return [pos_x * obj_manager.cell_size, pos_y * obj_manager.cell_size];
		}
	}
}