//create grid
cell_size = 32;
map_grid = mp_grid_create(0 ,0, room_width/cell_size, room_height/cell_size, cell_size, cell_size);

mp_grid_add_instances(map_grid, obj_obstacle, false);

/*var ocuppied_cells = [];
for (var i = 0; i < room_height/cell_size; i++) {
    for (var j = 0; j < room_width/cell_size; j++) {

        if (mp_grid_get_cell(map_grid, i, j) == -1) {
			
			array_push(ocuppied_cells, [i,j]);
        }
    }
}

for (var i = 0; i < array_length(ocuppied_cells); i++){
	        mp_grid_add_cell(map_grid, ocuppied_cells[i][0] + 1, ocuppied_cells[i][1]);
            mp_grid_add_cell(map_grid, ocuppied_cells[i][0] - 1, ocuppied_cells[i][1]);
            mp_grid_add_cell(map_grid, ocuppied_cells[i][0], ocuppied_cells[i][1] + 1);
            mp_grid_add_cell(map_grid, ocuppied_cells[i][0], ocuppied_cells[i][1] - 1);
			mp_grid_add_cell(map_grid, ocuppied_cells[i][0] + 1, ocuppied_cells[i][1] + 1);
			mp_grid_add_cell(map_grid, ocuppied_cells[i][0] - 1, ocuppied_cells[i][1] - 1);
			mp_grid_add_cell(map_grid, ocuppied_cells[i][0] + 1, ocuppied_cells[i][1] - 1);
			mp_grid_add_cell(map_grid, ocuppied_cells[i][0] - 1, ocuppied_cells[i][1] + 1);

}
*/