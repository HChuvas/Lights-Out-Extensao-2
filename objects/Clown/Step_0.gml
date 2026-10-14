var _saw_player = false;
if (instance_exists(Player)) {
    var _d = point_distance(x, y, Player.x, Player.y);
    _saw_player = (_d <= sight_radius) && !wall_line(x, y, Player.x, Player.y);
}

arm_cooldown = max(0, arm_cooldown - 1);

switch (state) {
    case CLOWN.IDLE:
        idle_timer--;

        if (_saw_player) {
            start_flee();
        }
        else if (arm_cooldown <= 0 && instance_number(Balloon) < max_balloons) {
            state = CLOWN.ARM;
        }
        else if (idle_timer <= 0) {
            if (irandom(99) < 40 && go_to(irandom_range(32, room_width - 32), irandom_range(32, room_height - 32), patrol_spd)) {
                state = CLOWN.PATROL;
            } else {
                idle_timer = 2 * game_fps;
            }
        }
    break;

    case CLOWN.ARM:
        if (!arm_ready) {
            var _spot = pick_item_spot(Balloon, balloon_min_dist);

            if (_spot != undefined && go_to(_spot.x, _spot.y, patrol_spd)) {
                arm_ready = true;
            } else {
                arm_cooldown = game_fps;
                state = CLOWN.IDLE;
            }
        }
        else if (_saw_player) {
            start_flee();
        }
        else if (path_index == -1) {
            spawn_item(Balloon, x, y, max_balloons);

            arm_ready = false;
            arm_cooldown = 5 * game_fps;
            idle_timer = 2 * game_fps;
            state = CLOWN.IDLE;
        }
    break;

    case CLOWN.PATROL:
        if (_saw_player) {
            start_flee();
        }
        else if (path_index == -1) {
            idle_timer = 2 * game_fps;
            state = CLOWN.IDLE;
        }
    break;

    case CLOWN.FLEE:
        flee_timer--;

        if (path_index == -1 && instance_exists(Player)) {
            flee_from(Player.x, Player.y, 120, flee_spd);
        }

        if (flee_timer <= 0) {
            path_end();
            idle_timer = 2 * game_fps;
            state = CLOWN.IDLE;
        }
    break;
}