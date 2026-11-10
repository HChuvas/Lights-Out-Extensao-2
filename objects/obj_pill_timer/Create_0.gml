var timer_destroy = function () {
    global.frozen = false;
    instance_destroy(self);
}

var _timer = time_source_create(time_source_game, 5, time_source_units_seconds, timer_destroy);
time_source_start(_timer);
global.frozen = true;