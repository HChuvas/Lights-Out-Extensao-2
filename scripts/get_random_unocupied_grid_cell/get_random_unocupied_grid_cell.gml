function get_random_unocupied_grid_cell(grid){
	var pos_x, pos_y;
	
	while(true){
		pos_x = irandom_range(obj_manager.patrol_x1 / obj_manager.cell_size, (obj_manager.patrol_x2 / obj_manager.cell_size) - 1);
		pos_y = irandom_range(obj_manager.patrol_y1 / obj_manager.cell_size, (obj_manager.patrol_y2 / obj_manager.cell_size) - 1);
	
		if(mp_grid_get_cell(grid, pos_x, pos_y) == 0){
			return [pos_x * obj_manager.cell_size, pos_y * obj_manager.cell_size];
		}
	}
}