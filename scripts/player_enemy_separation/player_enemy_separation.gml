function player_enemy_separation(_radius = 25, _strength = 0.5, _max_push = 2) {

    var _tilemap = layer_tilemap_get_id("Collision");
    var _count = instance_number(enemy_parent);

    for (var i = 0; i < _count; i++) {
        var _enemy = instance_find(enemy_parent, i);

        if (!instance_exists(_enemy)) {
            continue;
        }

        var _dx = _enemy.x - x;
        var _dy = _enemy.y - y;
        var _dist = point_distance(x, y, _enemy.x, _enemy.y);

        if (_dist >= _radius) {
            continue;
        }

        if (_dist < 0.001) {
            _dx = 1;
            _dy = 0;
            _dist = 1;
        }

        var _force = min(
            (_radius - _dist) * _strength,
            _max_push
        );

        var _push_x = (_dx / _dist) * _force;
        var _push_y = (_dy / _dist) * _force;

        // Move enemy
        with (_enemy) {

            // Collision X
            var _new_x = x + _push_x;
            var _blocked_x = place_meeting(_new_x, y, obj_obstacle);

            if (!_blocked_x && _tilemap != -1) {
                _blocked_x =
                    tilemap_get_at_pixel(_tilemap, bbox_left + _push_x, bbox_top) != 0 ||
                    tilemap_get_at_pixel(_tilemap, bbox_right + _push_x, bbox_top) != 0 ||
                    tilemap_get_at_pixel(_tilemap, bbox_left + _push_x, bbox_bottom) != 0 ||
                    tilemap_get_at_pixel(_tilemap, bbox_right + _push_x, bbox_bottom) != 0;
            }

            if (!_blocked_x) {
                x = _new_x;
            }

            // Collision Y
            var _new_y = y + _push_y;
            var _blocked_y = place_meeting(x, _new_y, obj_obstacle);

            if (!_blocked_y && _tilemap != -1) {
                var _offset_y = _new_y - y;

                _blocked_y =
                    tilemap_get_at_pixel(_tilemap, bbox_left, bbox_top + _offset_y) != 0 ||
                    tilemap_get_at_pixel(_tilemap, bbox_right, bbox_top + _offset_y) != 0 ||
                    tilemap_get_at_pixel(_tilemap, bbox_left, bbox_bottom + _offset_y) != 0 ||
                    tilemap_get_at_pixel(_tilemap, bbox_right, bbox_bottom + _offset_y) != 0;
            }

            if (!_blocked_y) {
                y = _new_y;
            }
        }
    }
}