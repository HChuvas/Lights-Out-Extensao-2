function alert_nearest_enemy(_x, _y, _radius) {
    var _best = noone;
    var _best_d = _radius;

    with (enemy_parent) {
        if (!can_hear_alert()) continue;
        var _d = point_distance(x, y, _x, _y);
        if (_d < _best_d) {
            _best_d = _d;
            _best = id;
        }
    }

    if (_best == noone) return false;
    return _best.hear_alert(_x, _y);
}