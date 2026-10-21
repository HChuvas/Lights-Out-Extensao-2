// Checagem inicial
if (!variable_global_exists("cell") || !variable_global_exists("solid_maps")) exit;

// Cria o grid uma vez
if (!ready) {
    build_grid();
    ready = true;
}

// Atualizações por frame
arm_cooldown = max(0, arm_cooldown - 1);
alert_cd = max(0, alert_cd - 1);
follow_path();
watchdog();

// Visão
var _see = false;
if (instance_exists(Player)) {
    _see = (point_distance(x, y, Player.x, Player.y) <= sight_radius) && !wall_line(x, y, Player.x, Player.y);
}

// Transição para fuga
if (_see && state != CLOWN.FLEE) {
    start_flee();
    update_anim();
    exit;
}

// Máquina de estados
switch (state) {

    case CLOWN.IDLE:
        idle_timer--;

        if (arm_cooldown <= 0 && instance_number(Balloon) < max_balloons) {
            if (go_random(arm_spd, balloon_min_dist, true)
             || go_random(arm_spd, balloon_min_dist)
             || go_random(arm_spd, balloon_min_dist * 0.5)) {
                state = CLOWN.ARM;
            } else {
                arm_cooldown = tps;
            }
        }
        else if (idle_timer <= 0) {
            idle_timer = 2 * tps;

            if (irandom(99) < 40 && go_random(patrol_spd)) {
                state = CLOWN.PATROL;
            }
        }
    break;

    case CLOWN.PATROL:
        if (on_path) break;
        idle_timer = 2 * tps;
        state = CLOWN.IDLE;
    break;

    case CLOWN.ARM:
        if (on_path) break;

        if (arrived && instance_number(Balloon) < max_balloons) {
            instance_create_layer(x, y, "Instances", Balloon);
            arm_cooldown = arm_cd_time;
        } else {
            arm_cooldown = arm_fail_time;
        }

        idle_timer = 2 * tps;
        state = CLOWN.IDLE;
    break;

    case CLOWN.FLEE:
        flee_timer--;
        repath_t--;
        panic = false;

        if (_see) flee_timer = max(flee_timer, 2 * tps);

        if (instance_exists(Player)) {
            var _pd = point_distance(x, y, Player.x, Player.y);

            if (repath_t <= 0 && _pd < sight_radius * 1.5 && (!on_path || path_near_player())) {
                repath_t = flee_from(Player.x, Player.y) ? round(0.5 * tps) : round(0.2 * tps);
            }

            // Fallback anti-bodyblock
            if (!on_path && _pd < sight_radius * 1.5) {
                var _away = point_direction(Player.x, Player.y, x, y);
                var _offs = [0, 45, -45, 90, -90];

                panic = step_toward(_away + panic_off, flee_spd);

                for (var _k = 0; _k < 5 && !panic; _k++) {
                    if (_offs[_k] == panic_off) continue;
                    if (step_toward(_away + _offs[_k], flee_spd)) {
                        panic = true;
                        panic_off = _offs[_k];
                    }
                }
            }
        }

        if (flee_timer <= 0) {
            on_path = false;
            panic = false;
            idle_timer = 2 * tps;
            state = CLOWN.IDLE;
        }
    break;
}

update_anim();
enemy_separation();