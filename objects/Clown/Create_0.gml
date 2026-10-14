enum CLOWN { IDLE, ARM, PATROL, FLEE }

state = CLOWN.IDLE;

patrol_spd = 0.5;
flee_spd = 1.25;
sight_radius = 90;
max_balloons = 10;
balloon_min_dist = 64;
arm_ready = false;

game_fps = game_get_speed(gamespeed_fps);
arm_cooldown = 5 * game_fps;
idle_timer = 2 * game_fps;
flee_timer = 0;

move_path = path_add();

// paredes (tilemaps)
wall_line = function(_x1, _y1, _x2, _y2) {
    for (var _i = 0; _i < array_length(global.solid_maps); _i++) {
        if (collision_line(_x1, _y1, _x2, _y2, global.solid_maps[_i], false, true) != noone) return true;
    }
    return false;
}

wall_circle = function(_x, _y, _r) {
    for (var _i = 0; _i < array_length(global.solid_maps); _i++) {
        if (collision_circle(_x, _y, _r, global.solid_maps[_i], false, true) != noone) return true;
    }
    return false;
}

// itens
pick_item_spot = function(_item_obj, _min_dist, _tries = 20, _margin = 32) {
    repeat (_tries) {
        var _px = irandom_range(_margin, room_width - _margin);
        var _py = irandom_range(_margin, room_height - _margin);

        var _free = !wall_circle(_px, _py, 8);
        var _near = instance_nearest(_px, _py, _item_obj);
        var _far = (_near == noone) || (point_distance(_px, _py, _near.x, _near.y) >= _min_dist);

        if (_free && _far) return { x: _px, y: _py };
    }
    return undefined;
}

spawn_item = function(_item_obj, _x, _y, _max_items, _layer = "Instances") {
    if (instance_number(_item_obj) >= _max_items) return noone;
    return instance_create_layer(_x, _y, _layer, _item_obj);
}

// movimento
go_to = function(_x, _y, _spd) {
    if (mp_grid_path(global.grid, move_path, x, y, _x, _y, false)) {
        path_start(move_path, _spd, path_action_stop, true);
        return true;
    }
    return false;
}

flee_from = function(_px, _py, _dist, _spd) {
    var _dir = point_direction(_px, _py, x, y);
    repeat (8) {
        var _a = _dir + irandom_range(-70, 70);
        var _tx = clamp(x + lengthdir_x(_dist, _a), 32, room_width - 32);
        var _ty = clamp(y + lengthdir_y(_dist, _a), 32, room_height - 32);
        if (go_to(_tx, _ty, _spd)) return true;
    }
    return false;
}

start_flee = function() {
    path_end();
    arm_ready = false;
    flee_timer = 3 * game_fps;
    flee_from(Player.x, Player.y, 120, flee_spd);
    state = CLOWN.FLEE;
}