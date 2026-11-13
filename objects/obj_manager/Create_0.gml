patrol_x1 = 0;
patrol_y1 = 0;
patrol_x2 = 500;
patrol_y2 = 400;

if (room == r_middle_room) {
    patrol_x1 = 330;
    patrol_y1 = 140;
    patrol_x2 = 820;
    patrol_y2 = 630;
}
//create grid
cell_size = 16;
map_grid = mp_grid_create(0 ,0, room_width/cell_size, room_height/cell_size, cell_size, cell_size);

mp_grid_add_instances(map_grid, obj_obstacle, false);
