function player_enemy_separation(_left, _top, _right, _bottom, _strength = 0.5, _max_push = 2) {

    var _tilemap = layer_tilemap_get_id("Collision");
    var _count = instance_number(enemy_parent);

    for (var i = 0; i < _count; i++) {

        var _enemy = instance_find(enemy_parent, i);

        if (_enemy == id || !instance_exists(_enemy)) {
            continue;
        }

        // Verifica se o inimigo está dentro da área retangular
        if (
            _enemy.x < _left ||
            _enemy.x > _right ||
            _enemy.y < _top ||
            _enemy.y > _bottom
        ) {
            continue;
        }

        // Calcula a direção de afastamento
        var _center_x = (_left + _right) * 0.5;
        var _center_y = (_top + _bottom) * 0.5;

        var _dx = _enemy.x - _center_x;
        var _dy = _enemy.y - _center_y;

        var _dist = point_distance(0, 0, _dx, _dy);

        if (_dist < 0.001) {
            _dx = 1;
            _dy = 0;
            _dist = 1;
        }

        var _force = min(_dist * _strength, _max_push);

        var _push_x = (_dx / _dist) * _force;
        var _push_y = (_dy / _dist) * _force;

        var _push = {
            x: _push_x,
            y: _push_y,
            tilemap: _tilemap
        };

        // Colisão no eixo X
        with (_enemy) {

            var _new_x = x + _push.x;
            var _blocked_x = place_meeting(_new_x, y, obj_obstacle);

            if (!_blocked_x && _push.tilemap != -1) {
                _blocked_x =
                    tilemap_get_at_pixel(_push.tilemap, bbox_left + _push.x, bbox_top) != 0 ||
                    tilemap_get_at_pixel(_push.tilemap, bbox_right + _push.x, bbox_top) != 0 ||
                    tilemap_get_at_pixel(_push.tilemap, bbox_left + _push.x, bbox_bottom) != 0 ||
                    tilemap_get_at_pixel(_push.tilemap, bbox_right + _push.x, bbox_bottom) != 0;
            }

            if (!_blocked_x) {
                x = _new_x;
            }

            // Colisão no eixo Y
            var _new_y = y + _push.y;
            var _blocked_y = place_meeting(x, _new_y, obj_obstacle);

            if (!_blocked_y && _push.tilemap != -1) {
                var _offset_y = _new_y - y;

                _blocked_y =
                    tilemap_get_at_pixel(_push.tilemap, bbox_left, bbox_top + _offset_y) != 0 ||
                    tilemap_get_at_pixel(_push.tilemap, bbox_right, bbox_top + _offset_y) != 0 ||
                    tilemap_get_at_pixel(_push.tilemap, bbox_left, bbox_bottom + _offset_y) != 0 ||
                    tilemap_get_at_pixel(_push.tilemap, bbox_right, bbox_bottom + _offset_y) != 0;
            }

            if (!_blocked_y) {
                y = _new_y;
            }
        }
    }
}