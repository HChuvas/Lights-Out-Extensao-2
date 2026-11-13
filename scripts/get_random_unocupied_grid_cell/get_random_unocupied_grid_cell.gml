// true se a célula existe no grid e está livre
function mp_cell_free(_grid, _cx, _cy){
	var _cs = obj_manager.cell_size;
	if (_cx < 0 || _cy < 0 || _cx >= room_width div _cs || _cy >= room_height div _cs) return false;
	return mp_grid_get_cell(_grid, _cx, _cy) == 0;
}

// devolve o centro da célula livre mais próxima
function mp_snap_to_free(_grid, _x, _y, _max_r = 4){
	var _cs = obj_manager.cell_size;
	var _cx = floor(_x / _cs), _cy = floor(_y / _cs);
	for (var _r = 0; _r <= _max_r; _r++){
		for (var _dx = -_r; _dx <= _r; _dx++){
			for (var _dy = -_r; _dy <= _r; _dy++){
				if (max(abs(_dx), abs(_dy)) != _r) continue;
				if (mp_cell_free(_grid, _cx + _dx, _cy + _dy)){
					return [(_cx + _dx) * _cs + _cs / 2, (_cy + _dy) * _cs + _cs / 2];
				}
			}
		}
	}
	return undefined;
}

function get_random_unocupied_grid_cell(grid){
	var _cs = obj_manager.cell_size;
	for (var _i = 0; _i < 100; _i++){
		var pos_x = irandom_range(obj_manager.patrol_x1 / _cs, (obj_manager.patrol_x2 / _cs) - 1);
		var pos_y = irandom_range(obj_manager.patrol_y1 / _cs, (obj_manager.patrol_y2 / _cs) - 1);
		if (mp_cell_free(grid, pos_x, pos_y)){
			return [pos_x * _cs + _cs / 2, pos_y * _cs + _cs / 2];
		}
	}
	return [x, y]; // sem célula livre, fica parado
}
