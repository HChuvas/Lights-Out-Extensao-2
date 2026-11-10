function enemy_separation() {
    var _radius = 25;
    var _strength = 0.5;
    var _max_push = 2;

    var _tilemap = layer_tilemap_get_id("Collision");
    var _count = instance_number(obj_chaser);

    for (var i = 0; i < _count; i++) {
        var _enemy = instance_find(obj_chaser, i);

        if (_enemy == id || !instance_exists(_enemy)) {
            continue;
        }

        var _dx = x - _enemy.x;
        var _dy = y - _enemy.y;
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

        var _push_x = (_dx / _dist) * _force * 0.5;
        var _push_y = (_dy / _dist) * _force * 0.5;

        var _push = {
            x: _push_x,
            y: _push_y,
            tilemap: _tilemap
        };

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

        if (instance_exists(_enemy)) {
            with (_enemy) {
                var _ex = x - _push.x;
                var _block_x = place_meeting(_ex, y, obj_obstacle);

                if (!_block_x && _push.tilemap != -1) {
                    var _off_x = _ex - x;

                    _block_x =
                        tilemap_get_at_pixel(_push.tilemap, bbox_left + _off_x, bbox_top) != 0 ||
                        tilemap_get_at_pixel(_push.tilemap, bbox_right + _off_x, bbox_top) != 0 ||
                        tilemap_get_at_pixel(_push.tilemap, bbox_left + _off_x, bbox_bottom) != 0 ||
                        tilemap_get_at_pixel(_push.tilemap, bbox_right + _off_x, bbox_bottom) != 0;
                }

                if (!_block_x) {
                    x = _ex;
                }

                var _ey = y - _push.y;
                var _block_y = place_meeting(x, _ey, obj_obstacle);

                if (!_block_y && _push.tilemap != -1) {
                    var _off_y = _ey - y;

                    _block_y =
                        tilemap_get_at_pixel(_push.tilemap, bbox_left, bbox_top + _off_y) != 0 ||
                        tilemap_get_at_pixel(_push.tilemap, bbox_right, bbox_top + _off_y) != 0 ||
                        tilemap_get_at_pixel(_push.tilemap, bbox_left, bbox_bottom + _off_y) != 0 ||
                        tilemap_get_at_pixel(_push.tilemap, bbox_right, bbox_bottom + _off_y) != 0;
                }

                if (!_block_y) {
                    y = _ey;
                }
            }
        }
    }
}