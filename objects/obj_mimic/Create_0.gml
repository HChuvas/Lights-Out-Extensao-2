event_inherited();

enum MIMIC_STATES { IDLE, ATTACK }
state = MIMIC_STATES.IDLE;
sprite_index = spr_mimic_idle;

// ajustes
trigger_dist    = 24;
idle_time       = [20, 40];
windup_time     = 0.3;
attack_time     = 5;
attack_damage   = 1;
attack_lifetime = 0.5;

// preenchidos pelo procgen_spawn_mimics
if (!variable_instance_exists(id, "shared")) { shared = undefined; cell_i = -1; }

timer = irandom_range(idle_time[0], idle_time[1]) * game_get_speed(gamespeed_fps);
attacked = false;

wall_line = function(_x1, _y1, _x2, _y2) {
    if (collision_line(_x1, _y1, _x2, _y2, obj_obstacle, false, true) != noone) return true;
    for (var _i = 0; _i < array_length(global.solid_maps); _i++) {
        if (collision_line(_x1, _y1, _x2, _y2, global.solid_maps[_i], false, true) != noone) return true;
    }
    return false;
}

// o jogador vê esse ponto
player_sees = function(_x, _y) {
    var _c = view_camera[0];
    var _vx = camera_get_view_x(_c), _vy = camera_get_view_y(_c);
    if (_x < _vx || _y < _vy || _x > _vx + camera_get_view_width(_c) || _y > _vy + camera_get_view_height(_c)) return false;
    var _a = point_direction(_x, _y, Player.x, Player.y);
    return !wall_line(_x + lengthdir_x(12, _a), _y + lengthdir_y(12, _a), Player.x, Player.y);
}

// teleporta para outra cadeira
relocate = function() {
    if (shared == undefined || player_sees(x, y)) return false; // não some na cara do jogador
    var _opts = [];
    for (var _i = 0; _i < array_length(shared.cells); _i++) {
        if (shared.taken[_i]) continue;
        var _c = shared.cells[_i];
        if (!player_sees(_c.px, _c.py)) array_push(_opts, _i);
    }
    if (array_length(_opts) == 0) return false;

    var _new = _opts[irandom(array_length(_opts) - 1)];
    var _old = shared.cells[cell_i];
    layer_sprite_alpha(_old.el, 1); // cadeira antiga volta
    shared.taken[cell_i] = false;

    var _n = shared.cells[_new];
    layer_sprite_alpha(_n.el, 0); // cadeira nova some
    shared.taken[_new] = true;
    cell_i = _new;
    x = _n.px;
    y = _n.py;
    return true;
}