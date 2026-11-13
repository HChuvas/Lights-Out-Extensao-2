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
