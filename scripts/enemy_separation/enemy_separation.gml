function enemy_separation() {
    var _radius = 25;
    var _strength = 1;
    var _max_push = 2;

    var _count = instance_number(obj_chaser);

    for (var i = 0; i < _count; i++) {
        var _enemy = instance_find(obj_chaser, i);

        if (_enemy == id || !instance_exists(_enemy)) {
            continue;
        }

        var _dx = x - _enemy.x;
        var _dy = y - _enemy.y;
        var _dist = point_distance(x, y, _enemy.x, _enemy.y);

        if (_dist < _radius) {

            var _force = min( (_radius - _dist) * _strength,  _max_push);

            var _push_x = (_dx / _dist) * _force;
            var _push_y = (_dy / _dist) * _force;

        if (!place_meeting(x + _dx, y, [obj_obstacle, enemy_parent])) { x += _push_x; }  
		if (!place_meeting(x, y + _dy, [obj_obstacle, enemy_parent])) { y += _push_y; } 
        }
    }
}