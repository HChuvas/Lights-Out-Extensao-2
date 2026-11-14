// Parede para o empurrão
function separation_blocked(_x, _y) {
    if (place_meeting(_x, _y, obj_obstacle)) return true;
    if (variable_global_exists("solid_maps")) {
        for (var _i = 0; _i < array_length(global.solid_maps); _i++) {
            if (place_meeting(_x, _y, global.solid_maps[_i])) return true;
        }
    }
    return false;
}

// Move a instância um pouco, eixo por eixo, sem entrar em parede
function separation_nudge(_inst, _mx, _my) {
    with (_inst) {
        if (!separation_blocked(x + _mx, y)) x += _mx;
        if (!separation_blocked(x, y + _my)) y += _my;
    }
}

function enemy_separation(_radius = 25, _strength = 0.5, _max_push = 2, _self = true, obj_to_aply = enemy_parent) {
    // Inimigos congelados (pílula, troca de sala) não devem ser empurrados
    if (variable_global_exists("frozen") && global.frozen) return;

    // Limite do empurrão
    var _cap = min(_max_push, 2);
    var _count = instance_number(obj_to_aply);

    for (var i = 0; i < _count; i++) {
        var _enemy = instance_find(obj_to_aply, i);

        if (_enemy == id || !instance_exists(_enemy)) continue;

        var _dx = x - _enemy.x;
        var _dy = y - _enemy.y;
        var _dist = point_distance(x, y, _enemy.x, _enemy.y);

        if (_dist >= _radius) continue;

        if (_dist < 0.001) {
            _dx = 1;
            _dy = 0;
            _dist = 1;
        }

        var _force = min((_radius - _dist) * _strength, _cap);
        var _push_x = (_dx / _dist) * _force * 0.5;
        var _push_y = (_dy / _dist) * _force * 0.5;

        if (_self) separation_nudge(id, _push_x, _push_y);
        separation_nudge(_enemy, -_push_x, -_push_y);
    }
}

// :3

// Depth dos inimigos
function enemy_depth() {
    return (room == r_starting_room) ? 460 : 330;
}

// Coloca a instância numa layer com o depth de enemy_depth().
function enemy_put_on_layer() {
    var _n = "EnemyDepthLayer";
    if (!layer_exists(_n)) layer_create(enemy_depth(), _n);
    layer_add_instance(_n, id);
}


// Redesenha por cima do inimigo apenas paredes e batentes de porta
function draw_enemy_over_world(_l, _t, _r, _b, _feet) {
    var _has_front = variable_global_exists("pg_front") && variable_global_exists("pg_front_room") && global.pg_front_room == room;
    var _wmaps = [];
    var _wnames = ["Walls", "WallLayer", "Tiles_1"];
    for (var _wn = 0; _wn < array_length(_wnames); _wn++) {
        if (layer_exists(_wnames[_wn])) {
            var _wlm = layer_tilemap_get_id(_wnames[_wn]);
            if (_wlm != -1) array_push(_wmaps, _wlm);
        }
    }
    var _fmap = -1; // batentes de porta
    if (variable_global_exists("pg_frames_map") && _has_front && global.pg_frames_map != -1) _fmap = global.pg_frames_map;
    if (array_length(_wmaps) == 0 && _fmap == -1) exit;

    // recorta o redesenho
    var _clip = view_enabled && view_visible[0];
    if (_clip) {
        var _cam = view_camera[0];
        var _vx = camera_get_view_x(_cam), _vy = camera_get_view_y(_cam);
        var _kx = surface_get_width(application_surface) / camera_get_view_width(_cam);
        var _ky = surface_get_height(application_surface) / camera_get_view_height(_cam);
        var _sx0 = floor((_l - _vx) * _kx), _sy0 = floor((_t - _vy) * _ky);
        var _sx1 = ceil((_r - _vx) * _kx),  _sy1 = ceil((_b - _vy) * _ky);
        var _old_scissor = gpu_get_scissor();
        gpu_set_scissor(_sx0, _sy0, _sx1 - _sx0, _sy1 - _sy0);
    }

    // paredes
    var _wall_hit = false;
    for (var _m = 0; _m < array_length(_wmaps); _m++) {
        if (enemy_redraw_tiles(_wmaps[_m], _l, _t, _r, _b, _feet)) _wall_hit = true;
    }

    // batentes e portas
    if (_fmap != -1) enemy_redraw_tiles(_fmap, _l, _t, _r, _b, _feet);

    if (_clip) gpu_set_scissor(_old_scissor);
}

// Redesenha os tiles de um tilemap
function enemy_redraw_tiles(_wm, _l, _t, _r, _b, _feet) {
    var _drew = false;
    var _wtw = tilemap_get_tile_width(_wm), _wth = tilemap_get_tile_height(_wm);
    var _wmx = tilemap_get_x(_wm), _wmy = tilemap_get_y(_wm);
    var _wts = tilemap_get_tileset(_wm);

    var _cx0 = floor((_l - _wmx) / _wtw), _cx1 = floor((_r - 1 - _wmx) / _wtw);
    var _cy0 = floor((_t - _wmy) / _wth), _cy1 = floor((_b - 1 - _wmy) / _wth);
    
    for (var _cx = _cx0; _cx <= _cx1; _cx++) {
        for (var _cy = _cy0; _cy <= _cy1; _cy++) {
            var _td = tilemap_get(_wm, _cx, _cy);
            if (_td == -1 || tile_get_index(_td) == 0) continue;
            
            if (_wmy + (_cy + 1) * _wth <= _feet) {
                // parede acima dos pés
                var _fd = tilemap_get(_wm, _cx, floor((_feet - _wmy) / _wth));
                if (_fd == -1 || tile_get_index(_fd) == 0) continue;
            }
            
            var _tx = _wmx + _cx * _wtw;
            var _ty = _wmy + _cy * _wth;
            
            // Não desenha blocos de parede em cima de quadros
            var _overlaps_quadro = false;
            if (variable_global_exists("pg_front") && global.pg_front_room == room) {
                var _fl = global.pg_front;
                for (var _fi = 0; _fi < array_length(_fl); _fi++) {
                    var _f = _fl[_fi];
                    if (_tx + _wtw > _f.x && _tx < _f.x + _f.w && _ty + _wth > _f.y && _ty < _f.y + _f.h) {
                        _overlaps_quadro = true;
                        break;
                    }
                }
            }
            if (_overlaps_quadro) continue;

            draw_tile(_wts, _td, 0, _tx, _ty);
            _drew = true;
        }
    }
    return _drew;
}