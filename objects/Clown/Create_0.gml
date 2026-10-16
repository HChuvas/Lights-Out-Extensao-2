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

// Configurações de fuga e visão
flee_spd = 1.8;
flee_dist = 400;
flee_time = 6 * tps;
sight_radius = 90; // Raio de visão
max_balloons = 16;
balloon_min_dist = 64;

bad_spots = [];
bad_radius = 24;
bad_ttl = 15000;

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
wd_x = x;
wd_y = y;
wd_t = 0;

// Animação
face = "down";
panic = false;
panic_off = 0;      // direção de pânico que funcionou por último
walk_t = 0;         // frames restantes considerando "andando"
last_x = x;
last_y = y;

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
cell = 8;
cols = 0;
rows = 0;
reach = [];

// Métodos

// Atualiza o sprite de acordo com movimento e direção
update_anim = function() {
    // anda = se mexeu de verdade nos últimos frames (evita piscar idle/walk)
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

// Verifica se uma determinada posição colide com parede
hits_wall = function(_x, _y) {
    for (var _i = 0; _i < array_length(global.solid_maps); _i++) {
        if (place_meeting(_x, _y, global.solid_maps[_i])) return true;
    }
    return false;
}

// Colisão de movimento
hits_solid = function(_x, _y) {
    if (hits_wall(_x, _y)) return true;

    if (instance_exists(Player)
        && place_meeting(_x, _y, Player)
        && !place_meeting(x, y, Player)) return true;

    var _b = instance_place(_x, _y, Balloon);
    if (_b != noone && !_b.popping && !place_meeting(x, y, _b)) return true;

    return false;
}

// Verifica se existe linha de colisão entre dois pontos e qualquer mapa sólido
wall_line = function(_x1, _y1, _x2, _y2) {
    for (var _i = 0; _i < array_length(global.solid_maps); _i++) {
        if (collision_line(_x1, _y1, _x2, _y2, global.solid_maps[_i], false, true) != noone) return true;
    }
    return false;
}

// Constrói o grid de navegação usando a própria máscara do palhaço
// (place_meeting posiciona a máscara com a origem no ponto testado, igual ao movimento real)
build_safe_grid = function() {
    if (variable_global_exists("grid_safe")) mp_grid_destroy(global.grid_safe);
    global.grid_safe = mp_grid_create(0, 0, cols, rows, cell, cell);

    for (var _i = 0; _i < cols; _i++) {
        for (var _j = 0; _j < rows; _j++) {
            if (hits_wall(_i * cell + cell / 2, _j * cell + cell / 2)) {
                mp_grid_add_cell(global.grid_safe, _i, _j);
            }
        }
    }
    global.grid_room = room;
}

// Lista todas as células livres alcançáveis a partir da posição do palhaço
build_reachable = function() {
    var _seen = array_create(cols * rows, false);
    var _q = [];
    var _head = 0;

    var _ci = clamp(x div cell, 0, cols - 1);
    var _cj = clamp(y div cell, 0, rows - 1);
    var _found = false;
    for (var _r = 0; _r <= 3 && !_found; _r++) {
        for (var _a = _ci - _r; _a <= _ci + _r && !_found; _a++) {
            for (var _b = _cj - _r; _b <= _cj + _r && !_found; _b++) {
                if (_a < 0 || _b < 0 || _a >= cols || _b >= rows) continue;
                if (mp_grid_get_cell(global.grid_safe, _a, _b) == 0) {
                    array_push(_q, [_a, _b]);
                    _seen[_b * cols + _a] = true;
                    _found = true;
                }
            }
        }
    }

    var _dx = [1, -1, 0, 0];
    var _dy = [0, 0, 1, -1];
    while (_head < array_length(_q)) {
        var _c = _q[_head];
        _head++;
        for (var _d = 0; _d < 4; _d++) {
            var _nx = _c[0] + _dx[_d];
            var _ny = _c[1] + _dy[_d];
            if (_nx < 0 || _ny < 0 || _nx >= cols || _ny >= rows) continue;
            var _id = _ny * cols + _nx;
            if (_seen[_id]) continue;
            _seen[_id] = true;
            if (mp_grid_get_cell(global.grid_safe, _nx, _ny) != 0) continue;
            array_push(_q, [_nx, _ny]);
        }
    }

    reach = _q;
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
    if (!hits_solid(x + _dx, y)) x += _dx;
    if (!hits_solid(x, y + _dy)) y += _dy;

    var _moved = point_distance(_ox, _oy, x, y) > _spd * 0.3;

    // direção do olhar pelo deslocamento REAL, com histerese
    if (_moved) {
        var _ax = abs(x - _ox);
        var _ay = abs(y - _oy);
        if (_ax > _ay * 1.2)      face = (x > _ox) ? "right" : "left";
        else if (_ay > _ax * 1.2) face = (y > _oy) ? "down"  : "up";
    }
    return _moved;
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

// Gera um ponto livre e alcançável para ações do palhaço
free_point = function(_balloon_dist = 0, _open = false) {
    var _n = array_length(reach);
    if (_n == 0) return undefined;

    repeat (80) {
        var _c = reach[irandom(_n - 1)];
        var _i = _c[0];
        var _j = _c[1];

        if (_open) {
            var _ok = true;
            for (var _a = _i - 2; _a <= _i + 2 && _ok; _a++) {
                for (var _b = _j - 2; _b <= _j + 2 && _ok; _b++) {
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

// Marca no grid as células ocupadas por uma instância,
// expandidas pelo tamanho da máscara do palhaço (a rota mantém distância real)
block_box = function(_inst, _margin, _list) {
    var _el = x - bbox_left;
    var _er = bbox_right - x;
    var _et = y - bbox_top;
    var _eb = bbox_bottom - y;

    var _i0 = clamp(floor((_inst.bbox_left   - _er) / cell) - _margin, 0, cols - 1);
    var _i1 = clamp(floor((_inst.bbox_right  + _el) / cell) + _margin, 0, cols - 1);
    var _j0 = clamp(floor((_inst.bbox_top    - _eb) / cell) - _margin, 0, rows - 1);
    var _j1 = clamp(floor((_inst.bbox_bottom + _et) / cell) + _margin, 0, rows - 1);

    for (var _a = _i0; _a <= _i1; _a++) {
        for (var _b = _j0; _b <= _j1; _b++) {
            if (mp_grid_get_cell(global.grid_safe, _a, _b) == 0) {
                mp_grid_add_cell(global.grid_safe, _a, _b);
                array_push(_list, [_a, _b]);
            }
        }
    }
}

// Planeja o caminho utilizando o grid seguro
plan_path = function(_x, _y, _path = move_path) {
    var _ci = clamp(x div cell, 0, cols - 1);
    var _cj = clamp(y div cell, 0, rows - 1);

    // Raio de liberação proporcional ao tamanho da máscara
    var _ext = max(x - bbox_left, bbox_right - x, y - bbox_top, bbox_bottom - y);
    var _rad = ceil(_ext / cell) + 1;
    var _side = _rad * 2 + 1;

    // 1) registra as paredes reais ao redor ANTES de bloquear o dinâmico
    var _wall = array_create(_side * _side, false);
    for (var _a = _ci - _rad; _a <= _ci + _rad; _a++) {
        for (var _b = _cj - _rad; _b <= _cj + _rad; _b++) {
            if (_a < 0 || _b < 0 || _a >= cols || _b >= rows) continue;
            if (mp_grid_get_cell(global.grid_safe, _a, _b) != 0) {
                _wall[(_a - _ci + _rad) * _side + (_b - _cj + _rad)] = true;
            }
        }
    }

    // 2) bloqueia balões (menos o que o palhaço está tocando) e o player
    var _bal = [];
    with (Balloon) {
        if (popping) continue;
        if (place_meeting(x, y, other)) continue;
        other.block_box(id, 0, _bal);
    }
    if (instance_exists(Player)) block_box(Player, 0, _bal);

    // 3) se a célula inicial ficou bloqueada, abre só o entorno imediato (3x3),
    //    sem mexer em parede e sem liberar células mais perto do player
    if (mp_grid_get_cell(global.grid_safe, _ci, _cj) != 0) {
        var _has_p = instance_exists(Player);
        var _my_d = _has_p ? point_distance(x, y, Player.x, Player.y) : 0;

        for (var _a = _ci - 1; _a <= _ci + 1; _a++) {
            for (var _b = _cj - 1; _b <= _cj + 1; _b++) {
                if (_a < 0 || _b < 0 || _a >= cols || _b >= rows) continue;
                if (_wall[(_a - _ci + _rad) * _side + (_b - _cj + _rad)]) continue;
                if (mp_grid_get_cell(global.grid_safe, _a, _b) == 0) continue;

                var _own = (_a == _ci && _b == _cj);
                var _cx = _a * cell + cell / 2;
                var _cy = _b * cell + cell / 2;
                if (_own || !_has_p || point_distance(_cx, _cy, Player.x, Player.y) >= _my_d) {
                    mp_grid_clear_cell(global.grid_safe, _a, _b);
                }
            }
        }
    }

    // 4) se a célula inicial é parede real (palhaço raspando na parede), abre só o entorno imediato
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

    // 5) restaura o grid: paredes reais voltam, bloqueio dinâmico sai
    for (var _k = 0; _k < array_length(_saved); _k++) {
        mp_grid_add_cell(global.grid_safe, _saved[_k][0], _saved[_k][1]);
    }
    for (var _k = 0; _k < array_length(_bal); _k++) {
        mp_grid_clear_cell(global.grid_safe, _bal[_k][0], _bal[_k][1]);
    }
    return _ok;
}

// Configura um novo destino e inicia o deslocamento do palhaço
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
        if (!hits_solid(_tx, _ty)) { x = _tx; y = _ty; }
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

// A rota atual passa perto do player, mais perto dele do que o palhaço está agora?
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

// Calcula os melhores pontos para fugir da posição atual do player
flee_from = function(_px, _py) {
    var _my_d = point_distance(_px, _py, x, y);
    var _away = point_direction(_px, _py, x, y);
    var _min_far = max(sight_radius * 2, _my_d + 64);
    var _bx = undefined;
    var _by = 0;
    var _best = -1000000;
    var _nr = array_length(reach);

    for (var _pass = 0; _pass < 3 && _bx == undefined; _pass++) {
        if (_pass == 2 && _nr == 0) break;

        repeat (16) {
            var _r = random_range(flee_dist * 0.5, flee_dist);
            var _i, _j;

            if (_pass == 2) {
                var _c = reach[irandom(_nr - 1)];
                _i = _c[0];
                _j = _c[1];
            } else {
                var _a = (_pass == 0) ? _away + irandom_range(-90, 90) : irandom(359);
                _i = clamp((x + lengthdir_x(_r, _a)) div cell, 0, cols - 1);
                _j = clamp((y + lengthdir_y(_r, _a)) div cell, 0, rows - 1);
                if (mp_grid_get_cell(global.grid_safe, _i, _j) != 0) continue;
            }

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

// Ativa o comportamento de fuga ao avistar o player
start_flee = function() {
    on_path = false;
    flee_timer = flee_time;
    repath_t = 0;
    flee_from(Player.x, Player.y);
    state = CLOWN.FLEE;
}
