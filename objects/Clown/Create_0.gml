// Estados do palhaço
enum CLOWN { IDLE, PATROL, ARM, FLEE }

state = CLOWN.IDLE;
tps = game_get_speed(gamespeed_fps);

patrol_spd = 0.5;

// Ajustes de velocidade e cooldown
arm_rate = 1.20; 
arm_cd_time = round(5 * tps / arm_rate); 
arm_fail_time = round(2 * tps / arm_rate); 
arm_spd = patrol_spd * arm_rate;    
arm_cooldown = arm_cd_time;              

// Configurações de fuga e visão
flee_spd = 2.6;
flee_dist = 400;  
flee_time = 6 * tps;
sight_radius = 90; // Raio de visão
max_balloons = 10;
balloon_min_dist = 64; 

clear_r = 10; 
bad_spots = []; 
bad_radius = 48;
bad_ttl = 60000;

idle_timer = 2 * tps;
flee_timer = 0;
repath_t = 0;

// Controle de rota e movimento
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
plan_fail = 0;           
wd_x = x;                
wd_y = y;                
wd_t = 0;                

// Animação
face = "down";
// Sprites por direção
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

// Configurações de grid
ready = false;           
cell = 16;           
cols = 0;               
rows = 0;         

// Métodos

// Atualiza o sprite de acordo com movimento e direção
update_anim = function() {
    var _set = on_path ? spr_walk : spr_idle;
    var _spr = variable_struct_get(_set, face);

    if (sprite_index != _spr) {
        sprite_index = _spr;
        image_index = 0;
    }

    image_speed = (state == CLOWN.FLEE) ? 2 : 1;
}

// Verifica se uma determinada posição colide
hits_wall = function(_x, _y) {
    for (var _i = 0; _i < array_length(global.solid_maps); _i++) {
        if (place_meeting(_x, _y, global.solid_maps[_i])) return true;
    }
    return false;
}

// Verifica se existe linha de colisão entre dois pontos e qualquer mapa sólido
wall_line = function(_x1, _y1, _x2, _y2) {
    for (var _i = 0; _i < array_length(global.solid_maps); _i++) {
        if (collision_line(_x1, _y1, _x2, _y2, global.solid_maps[_i], false, true) != noone) return true;
    }
    return false;
}

// Constrói o grid de navegação com base na hitbox do palhaço
build_safe_grid = function() {
    if (variable_global_exists("grid_safe")) mp_grid_destroy(global.grid_safe);
    global.grid_safe = mp_grid_create(0, 0, cols, rows, cell, cell);

    for (var _i = 0; _i < cols; _i++) {
        for (var _j = 0; _j < rows; _j++) {
            var _cx = _i * cell + cell / 2;
            var _cy = _j * cell + cell / 2;
            var _bad = hits_wall(_cx, _cy);
            for (var _a = 0; _a < 360 && !_bad; _a += 45) {
                if (hits_wall(_cx + lengthdir_x(clear_r, _a), _cy + lengthdir_y(clear_r, _a))) _bad = true;
            }
            if (_bad) mp_grid_add_cell(global.grid_safe, _i, _j);
        }
    }
    global.grid_room = room;
}

// Adiciona um ponto problemático na lista de destinos ruins
add_bad = function(_x, _y) {
    array_push(bad_spots, { x: _x, y: _y, t: current_time });
    if (array_length(bad_spots) > 30) array_delete(bad_spots, 0, 1);
}

// Verifica se um ponto específico está próximo a um destino ruim
is_bad = function(_x, _y) {
    for (var _k = array_length(bad_spots) - 1; _k >= 0; _k--) {
        var _b = bad_spots[_k];
        if (current_time - _b.t > bad_ttl) { array_delete(bad_spots, _k, 1); continue; }
        if (point_distance(_x, _y, _b.x, _b.y) < bad_radius) return true;
    }
    return false;
}

// Tirar palhaço preso
unstick = function() {
    if (!hits_wall(x, y)) return;
    for (var _r = 1; _r <= 16; _r++) {
        for (var _a = 0; _a < 360; _a += 45) {
            var _nx = x + lengthdir_x(_r, _a);
            var _ny = y + lengthdir_y(_r, _a);
            if (!hits_wall(_nx, _ny)) { x = _nx; y = _ny; return; }
        }
    }
}

// Move o palhaço em direção a um ângulo
step_toward = function(_dir, _spd) {
    var _ox = x;
    var _oy = y;
    var _dx = lengthdir_x(_spd, _dir);
    var _dy = lengthdir_y(_spd, _dir);
    if (!hits_wall(x + _dx, y)) x += _dx;
    if (!hits_wall(x, y + _dy)) y += _dy;

    var _moved = point_distance(_ox, _oy, x, y) > _spd * 0.3;

    // Atualiza a direção do olhar (4 direções)
    if (_moved) {
        if (abs(_dx) > abs(_dy)) face = (_dx > 0) ? "right" : "left";
        else                     face = (_dy > 0) ? "down"  : "up";
    }
    return _moved;
}

// Opção de segurança
snap_to_safe = function() {
    var _ci = x div cell;
    var _cj = y div cell;
    var _bx = undefined;
    var _by = 0;
    var _bd = 1000000;

    for (var _r = 0; _r <= 10 && _bx == undefined; _r++) {
        for (var _a = _ci - _r; _a <= _ci + _r; _a++) {
            for (var _b = _cj - _r; _b <= _cj + _r; _b++) {
                if (_a < 0 || _b < 0 || _a >= cols || _b >= rows) continue;
                if (mp_grid_get_cell(global.grid_safe, _a, _b) != 0) continue;
                var _px = _a * cell + cell / 2;
                var _py = _b * cell + cell / 2;
                var _d = point_distance(x, y, _px, _py);
                if (_d < _bd) { _bd = _d; _bx = _px; _by = _py; }
            }
        }
    }

    if (_bx != undefined) { x = _bx; y = _by; }
    on_path = false;
    stuck_t = 0;
    wd_t = 0;
}

// Abandona o objetivo atual e marca o destino como ruim
abandon_goal = function() {
    add_bad(goal_x, goal_y);
    on_path = false;
    arrived = false;
    stuck_t = 0;
    wd_t = 0;
}

// Sistema de monitoramento
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

// Gera um ponto de coordenadas livres e válidas no grid seguro para ações do palhaço
free_point = function(_balloon_dist = 0, _open = false) {
    repeat (40) {
        var _i = irandom(cols - 1);
        var _j = irandom(rows - 1);
        if (mp_grid_get_cell(global.grid_safe, _i, _j) != 0) continue;

        if (_open) {
            var _ok = true;
            for (var _a = _i - 1; _a <= _i + 1 && _ok; _a++) {
                for (var _b = _j - 1; _b <= _j + 1 && _ok; _b++) {
                    if (_a < 0 || _b < 0 || _a >= cols || _b >= rows) { _ok = false; continue; }
                    if (mp_grid_get_cell(global.grid_safe, _a, _b) != 0) _ok = false;
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
        return { x: _px, y: _py };
    }
    return undefined;
}

// Planeja o caminho utilizando o grid seguro
plan_path = function(_x, _y, _path = move_path) {
    var _ci = x div cell;
    var _cj = y div cell;

    var _saved = [];
    if (mp_grid_get_cell(global.grid_safe, _ci, _cj) != 0) {
        for (var _a = _ci - 1; _a <= _ci + 1; _a++) {
            for (var _b = _cj - 1; _b <= _cj + 1; _b++) {
                if (_a < 0 || _b < 0 || _a >= cols || _b >= rows) continue;
                if (mp_grid_get_cell(global.grid_safe, _a, _b) != 0) {
                    array_push(_saved, [_a, _b]);
                    mp_grid_clear_cell(global.grid_safe, _a, _b);
                }
            }
        }
    }

    var _ok = mp_grid_path(global.grid_safe, _path, x, y, _x, _y, false);

    for (var _k = 0; _k < array_length(_saved); _k++) {
        mp_grid_add_cell(global.grid_safe, _saved[_k][0], _saved[_k][1]);
    }
    return _ok;
}

// Configura um novo destino e inicia o deslocamento do palhaço
go_to = function(_x, _y, _spd, _retry = 0) {
    if (!plan_path(_x, _y)) {
        add_bad(_x, _y);
        plan_fail++;
        if (plan_fail >= 3) {
            if (mp_grid_get_cell(global.grid_safe, x div cell, y div cell) != 0) snap_to_safe();
            plan_fail = 0;
        }
        return false;
    }
    plan_fail = 0;
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

// Executa o movimento ponto a ponto
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
        if (!hits_wall(_tx, _ty)) { x = _tx; y = _ty; }
        path_i++;
        stuck_t = 0;
        return;
    }

    var _dir = point_direction(x, y, _tx, _ty);
    var _moved = step_toward(_dir, move_spd);
    stuck_t = _moved ? 0 : stuck_t + 1;

    if (stuck_t > 12) {
        stuck_t = 0;
        unstick();
        if (retry_n < 1 && go_to(goal_x, goal_y, move_spd, retry_n + 1)) return;
        abandon_goal();
    }
}

// Calcula os melhores pontos para fugir da posição atual do player
flee_from = function(_px, _py) {
    var _my_d = point_distance(_px, _py, x, y);
    var _away = point_direction(_px, _py, x, y);
    var _min_far = max(sight_radius * 2, _my_d + 64);
    var _bx = undefined;
    var _by = 0;
    var _best = -1000000;

    for (var _pass = 0; _pass < 2 && _bx == undefined; _pass++) {
        repeat (30) {
            var _a = (_pass == 0) ? _away + irandom_range(-90, 90) : irandom(359);
            var _r = random_range(flee_dist * 0.5, flee_dist);
            var _i = clamp((x + lengthdir_x(_r, _a)) div cell, 0, cols - 1);
            var _j = clamp((y + lengthdir_y(_r, _a)) div cell, 0, rows - 1);
            if (mp_grid_get_cell(global.grid_safe, _i, _j) != 0) continue;

            var _tx = _i * cell + cell / 2;
            var _ty = _j * cell + cell / 2;
            var _d = point_distance(_px, _py, _tx, _ty);
            if (_d < ((_pass == 0) ? _min_far : _my_d + 16)) continue;
            if (!plan_path(_tx, _ty, eval_path)) continue;

            var _len = path_get_length(eval_path);
            var _near = 100000;
            for (var _t = 0.2; _t <= 1; _t += 0.2) {
                _near = min(_near, point_distance(_px, _py, path_get_x(eval_path, _t), path_get_y(eval_path, _t)));
            }
            if (_pass == 0 && (_near < _my_d - 16 || _len > _r * 2.5)) continue;

            var _score = 1.5 * _d + 2 * _near - 0.25 * _len;
            if (_score > _best) { _best = _score; _bx = _tx; _by = _ty; }
        }
    }

    return (_bx != undefined) && go_to(_bx, _by, flee_spd);
}

// Ativa o comportamento de fuga ao avistar o player
start_flee = function() {
    on_path = false;
    flee_timer = flee_time;
    repath_t = 0;
    flee_from(Player.x, Player.y);
    state = CLOWN.FLEE;
}