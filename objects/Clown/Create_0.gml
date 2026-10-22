event_inherited(); 

// Estados do palhaço
enum CLOWN { IDLE, PATROL, ARM, FLEE }

state = CLOWN.IDLE;
tps = game_get_speed(gamespeed_fps);

patrol_spd = 0.5;

// Ajustes de velocidade e cooldown
arm_rate = 1.5;
arm_cd_time = round(5 * tps / arm_rate);
arm_fail_time = round(2 * tps / arm_rate);
arm_spd = patrol_spd * arm_rate;
arm_cooldown = arm_cd_time;

// Fuga e visão
flee_spd = 1.8;
flee_dist = 400;
flee_time = 6 * tps;
sight_radius = 90;
max_balloons = 16;
balloon_min_dist = 64;

bad_spots = [];
bad_radius = 24;
bad_ttl = 15000;

idle_timer = 2 * tps;
flee_timer = 0;
repath_t = 0;

// Rota e movimento
move_path = path_add();
eval_path = path_add();
on_path = false;
arrived = false;
path_i = 0;
move_spd = 0;
stuck_t = 0;
goal_x = x;
goal_y = y;
retry_n = 0;
wd_x = x;
wd_y = y;
wd_t = 0;

// Alerta
alert_radius = 500;
alert_cd_time = 5 * tps; 
alert_cd = 0;

// Animação
face = "down";
panic = false;
panic_off = 0;
walk_t = 0;
last_x = x;
last_y = y;

spr_idle = {
    down:  spr_clown_idle_down,
    left:  spr_clown_idle_left,
    right: spr_clown_idle_right,
    up:    spr_clown_idle_up
};

spr_walk = {
    down:  spr_clown_walk_down,
    left:  spr_clown_walk_left,
    right: spr_clown_walk_right,
    up:    spr_clown_walk_up
};

// Grid 
ready = false;
grid = -1;
cell = 8;
cols = 0;
rows = 0;

// Métodos

update_anim = function() {
    if (point_distance(x, y, last_x, last_y) > 0.1) walk_t = 8;
    else walk_t = max(0, walk_t - 1);
    last_x = x;
    last_y = y;

    var _set = (walk_t > 0) ? spr_walk : spr_idle;
    var _spr = variable_struct_get(_set, face);

    if (sprite_index != _spr) {
        sprite_index = _spr;
        image_index = 0;
    }

    image_speed = (state == CLOWN.FLEE) ? 2 : 1;
}

// Parede
hits_wall = function(_x, _y) {
    if (place_meeting(_x, _y, obj_obstacle)) return true;
    for (var _i = 0; _i < array_length(global.solid_maps); _i++) {
        if (place_meeting(_x, _y, global.solid_maps[_i])) return true;
    }
    return false;
}

// Colisão de movimento
hits_solid = function(_x, _y) {
    if (hits_wall(_x, _y)) return !hits_wall(x, y);

    if (instance_exists(Player)
        && place_meeting(_x, _y, Player)
        && !place_meeting(x, y, Player)) return true;

    var _b = instance_place(_x, _y, Balloon);
    if (_b != noone && !_b.popping && !place_meeting(x, y, _b)) return true;

    return false;
}

wall_line = function(_x1, _y1, _x2, _y2) {
    if (collision_line(_x1, _y1, _x2, _y2, obj_obstacle, false, true) != noone) return true;
    for (var _i = 0; _i < array_length(global.solid_maps); _i++) {
        if (collision_line(_x1, _y1, _x2, _y2, global.solid_maps[_i], false, true) != noone) return true;
    }
    return false;
}

// Cria o mp_grid
build_grid = function() {
    cell = global.cell;
    cols = ceil(room_width / cell);
    rows = ceil(room_height / cell);

    if (grid != -1) mp_grid_destroy(grid);
    grid = mp_grid_create(0, 0, cols, rows, cell, cell);

    for (var _i = 0; _i < cols; _i++) {
        for (var _j = 0; _j < rows; _j++) {
            if (hits_wall(_i * cell + cell / 2, _j * cell + cell / 2)) {
                mp_grid_add_cell(grid, _i, _j);
            }
        }
    }
}

cell_free = function(_i, _j) {
    return _i >= 0 && _j >= 0 && _i < cols && _j < rows && mp_grid_get_cell(grid, _i, _j) == 0;
}

add_bad = function(_x, _y) {
    array_push(bad_spots, { x: _x, y: _y, t: current_time });
    if (array_length(bad_spots) > 30) array_delete(bad_spots, 0, 1);
}

is_bad = function(_x, _y) {
    for (var _k = array_length(bad_spots) - 1; _k >= 0; _k--) {
        var _b = bad_spots[_k];
        if (current_time - _b.t > bad_ttl) { array_delete(bad_spots, _k, 1); continue; }
        if (point_distance(_x, _y, _b.x, _b.y) < bad_radius) return true;
    }
    return false;
}

// Move em direção a um ângulo
step_toward = function(_dir, _spd) {
    var _ox = x;
    var _oy = y;
    var _dx = lengthdir_x(_spd, _dir);
    var _dy = lengthdir_y(_spd, _dir);
    if (!hits_solid(x + _dx, y)) x += _dx;
    if (!hits_solid(x, y + _dy)) y += _dy;

    var _moved = point_distance(_ox, _oy, x, y) > _spd * 0.3;

    if (_moved) {
        var _ax = abs(x - _ox);
        var _ay = abs(y - _oy);
        if (_ax > _ay * 1.2)      face = (x > _ox) ? "right" : "left";
        else if (_ay > _ax * 1.2) face = (y > _oy) ? "down"  : "up";
    }
    return _moved;
}

// Anda até um ponto
step_to_point = function(_tx, _ty, _spd) {
    var _ox = x;
    var _oy = y;
    var _dir = point_direction(x, y, _tx, _ty);
    var _dx = lengthdir_x(_spd, _dir);
    var _dy = lengthdir_y(_spd, _dir);

    var _mx = !hits_solid(x + _dx, y);
    if (_mx) x += _dx;
    var _my = !hits_solid(x, y + _dy);
    if (_my) y += _dy;

    if (_mx && !_my) {
        var _cx = clamp(_tx - x, -_spd, _spd);
        if (!hits_solid(x + _cx, y)) x += _cx;
    }
    else if (_my && !_mx) {
        var _cy = clamp(_ty - y, -_spd, _spd);
        if (!hits_solid(x, y + _cy)) y += _cy;
    }

    var _moved = point_distance(_ox, _oy, x, y) > _spd * 0.3;

    if (_moved) {
        var _ax = abs(x - _ox);
        var _ay = abs(y - _oy);
        if (_ax > _ay * 1.2)      face = (x > _ox) ? "right" : "left";
        else if (_ay > _ax * 1.2) face = (y > _oy) ? "down"  : "up";
    }
    return _moved;
}

abandon_goal = function() {
    add_bad(goal_x, goal_y);
    on_path = false;
    arrived = false;
    stuck_t = 0;
    wd_t = 0;
}

watchdog = function() {
    if (!on_path) { wd_x = x; wd_y = y; wd_t = 0; return; }

    if (point_distance(x, y, wd_x, wd_y) > 3) {
        wd_x = x;
        wd_y = y;
        wd_t = 0;
        return;
    }

    wd_t++;
    if (wd_t > tps) {
        abandon_goal();
        wd_x = x;
        wd_y = y;
    }
}

// Gera o path com mp_grid_path
plan_path = function(_x, _y, _path = move_path) {
    var _ci = clamp(x div cell, 0, cols - 1);
    var _cj = clamp(y div cell, 0, rows - 1);

    var _was = (mp_grid_get_cell(grid, _ci, _cj) != 0);
    if (_was) mp_grid_clear_cell(grid, _ci, _cj);

    var _ok = mp_grid_path(grid, _path, x, y, _x, _y, true);

    if (_was) mp_grid_add_cell(grid, _ci, _cj);
    return _ok;
}

go_to = function(_x, _y, _spd, _retry = 0) {
    if (!plan_path(_x, _y)) {
        add_bad(_x, _y);
        return false;
    }
    on_path = true;
    arrived = false;
    path_i = 0;
    move_spd = _spd;
    stuck_t = 0;
    wd_t = 0;
    goal_x = _x;
    goal_y = _y;
    retry_n = _retry;
    return true;
}

// Sorteia uma célula livre
go_random = function(_spd, _balloon_dist = 0, _open = false) {
    repeat (20) {
        var _i = irandom(cols - 1);
        var _j = irandom(rows - 1);
        if (!cell_free(_i, _j)) continue;

        if (_open) {
            var _ok = true;
            for (var _a = _i - 2; _a <= _i + 2 && _ok; _a++) {
                for (var _b = _j - 2; _b <= _j + 2 && _ok; _b++) {
                    if (!cell_free(_a, _b)) _ok = false;
                }
            }
            if (!_ok) continue;
        }

        var _px = _i * cell + cell / 2;
        var _py = _j * cell + cell / 2;
        if (is_bad(_px, _py)) continue;

        if (_balloon_dist > 0) {
            var _bl = instance_nearest(_px, _py, Balloon);
            if (_bl != noone && point_distance(_px, _py, _bl.x, _bl.y) < _balloon_dist) continue;
        }

        if (go_to(_px, _py, _spd)) return true;
    }
    return false;
}

follow_path = function() {
    if (!on_path) return;

    if (path_i >= path_get_number(move_path)) {
        on_path = false;
        arrived = true;
        return;
    }

    var _tx = path_get_point_x(move_path, path_i);
    var _ty = path_get_point_y(move_path, path_i);

    if (point_distance(x, y, _tx, _ty) <= move_spd) {
        path_i++;
        stuck_t = 0;
        return;
    }

    var _moved = step_to_point(_tx, _ty, move_spd);
    stuck_t = _moved ? 0 : stuck_t + 1;

    if (stuck_t > 12) {
        stuck_t = 0;
        if (retry_n < 1 && go_to(goal_x, goal_y, move_spd, retry_n + 1)) return;
        abandon_goal();
    }
}

path_near_player = function() {
    if (!on_path || !instance_exists(Player)) return false;

    var _my_d = point_distance(x, y, Player.x, Player.y);
    var _end = min(path_i + 6, path_get_number(move_path) - 1);

    for (var _k = path_i; _k <= _end; _k++) {
        var _d = point_distance(Player.x, Player.y, path_get_point_x(move_path, _k), path_get_point_y(move_path, _k));
        if (_d < 28 && _d < _my_d - 2) return true;
    }
    return false;
}

flee_from = function(_px, _py) {
    var _my_d = point_distance(_px, _py, x, y);
    var _away = point_direction(_px, _py, x, y);
    var _min_far = max(sight_radius * 2, _my_d + 64);
    var _bx = undefined;
    var _by = 0;
    var _best = -1000000;

    for (var _pass = 0; _pass < 3 && _bx == undefined; _pass++) {
        repeat (16) {
            var _r = random_range(flee_dist * 0.5, flee_dist);
            var _i, _j;

            if (_pass == 2) {
                _i = irandom(cols - 1);
                _j = irandom(rows - 1);
            } else {
                var _a = (_pass == 0) ? _away + irandom_range(-90, 90) : irandom(359);
                _i = clamp((x + lengthdir_x(_r, _a)) div cell, 0, cols - 1);
                _j = clamp((y + lengthdir_y(_r, _a)) div cell, 0, rows - 1);
            }
            if (!cell_free(_i, _j)) continue;

            var _tx = _i * cell + cell / 2;
            var _ty = _j * cell + cell / 2;
            var _d = point_distance(_px, _py, _tx, _ty);
            if (_d < ((_pass == 0) ? _min_far : _my_d + 16)) continue;
            if (!plan_path(_tx, _ty, eval_path)) continue;

            var _len = path_get_length(eval_path);
            var _near = 100000;
            for (var _t = 0.1; _t <= 1; _t += 0.1) {
                _near = min(_near, point_distance(_px, _py, path_get_x(eval_path, _t), path_get_y(eval_path, _t)));
            }
            if (_pass == 0 && (_near < _my_d - 16 || _len > _r * 2.5)) continue;

            var _score = 1.5 * _d + 2 * _near - 0.25 * _len;
            if (_score > _best) { _best = _score; _bx = _tx; _by = _ty; }
        }
    }

    return (_bx != undefined) && go_to(_bx, _by, flee_spd);
}


call_enemy = function() {
    if (alert_cd > 0) return false;
    if (!alert_nearest_enemy(x, y, alert_radius)) return false;

    alert_cd = alert_cd_time;
    return true;
}

start_flee = function() {
	audio_play_sound(clown_scream, 1, false);
    on_path = false;
    flee_timer = flee_time;
    repath_t = 0;
    flee_from(Player.x, Player.y);
    state = CLOWN.FLEE;
    call_enemy();
}