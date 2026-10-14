//create grid
cell_size = 32;
map_grid = mp_grid_create(0 ,0, room_width/cell_size, room_height/cell_size, cell_size, cell_size);

mp_grid_add_instances(map_grid, obj_obstacle, false);
