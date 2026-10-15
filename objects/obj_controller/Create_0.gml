global.solid_maps = [];
var _names = ["Walls", "Collision"];
for (var _k = 0; _k < array_length(_names); _k++) {
    if (layer_exists(_names[_k])) {
        var _map = layer_tilemap_get_id(_names[_k]);
        if (_map != -1) array_push(global.solid_maps, _map);
    }
}

global.cell = 16;
global.nav_margin = 6;
var _cols = ceil(room_width / global.cell);
var _rows = ceil(room_height / global.cell);
global.grid = mp_grid_create(0, 0, _cols, _rows, global.cell, global.cell);
for (var _i = 0; _i < _cols; _i++) {
    for (var _j = 0; _j < _rows; _j++) {
        var _x1 = _i * global.cell;
        var _y1 = _j * global.cell;
        var _x2 = _x1 + global.cell - 1;
        var _y2 = _y1 + global.cell - 1;
        var _m_ = global.nav_margin;

        for (var _m = 0; _m < array_length(global.solid_maps); _m++) {
            if (collision_rectangle(_x1 - _m_, _y1 - _m_, _x2 + _m_, _y2 + _m_, global.solid_maps[_m], false, false) != noone) {
                mp_grid_add_cell(global.grid, _i, _j);
                break;
            }
        }
    }
}