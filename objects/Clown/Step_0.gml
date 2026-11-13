// Congela inimigo no lugar caso necessário (ex: Pílula, troca de sala)
if (global.frozen == true) exit;

// Checagem inicial
if (!variable_global_exists("cell") || !variable_global_exists("solid_maps")) exit;

// Cria o grid uma vez
if (!ready) {
    enemy_unstick();
    build_grid();
    ready = true;
}

if (hits_wall(x, y) && enemy_unstick()) on_path = false;

// Lanterna atordoa o palhaço
if (in_flashlight_cone) {
    apply_flashlight_stun();
}
else if (state == CLOWN.STUNNED) {
    STUN_TIMER--;

    if (STUN_TIMER <= 0) {
        FLASHLIGHT_STUNNED = false;
        state = STATE_BEFORE_STUN;
        idle_timer = 2 * tps;
    }
}

if (state == CLOWN.STUNNED) {
    image_speed = 0;
    last_x = x;
    last_y = y;
    exit;
}

// Posição no começo do frame para evitar bugs
last_x = x;
last_y = y;

// Atualizações por frame
arm_cooldown = max(0, arm_cooldown - 1);
alert_cd = max(0, alert_cd - 1);

follow_path();
watchdog();


// Visão
var _see = see_player();


// Transição para fuga
if (_see && state != CLOWN.FLEE) {
    start_flee();
    update_anim();
    exit;
}


// Dá passagem
if ((state == CLOWN.IDLE || state == CLOWN.PATROL) && !on_path) {
    var _ch = instance_nearest(x, y, obj_chaser);

    if (_ch != noone && point_distance(x, y, _ch.x, _ch.y) < 28) {
        if (go_random(patrol_spd)) state = CLOWN.PATROL;
    }
}

// Máquina de estados :3
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

        if (arrived) {
            // chegou: fica parado um instante e então coloca o balão
            arrived = false;
            place_t = place_time;
            state = CLOWN.PLACE;
        } else {
            // caminho foi abandonado (bloqueado por alguém)
            arm_cooldown = arm_fail_time;
            idle_timer = 2 * tps;
            state = CLOWN.IDLE;
        }
    break;


    case CLOWN.PLACE:
        place_t--;
        if (place_t > 0) break;

        var _bl = instance_nearest(x, y, Balloon);
        var _clear = (instance_number(Balloon) < max_balloons)
                  && (_bl == noone || point_distance(x, y, _bl.x, _bl.y) >= balloon_min_dist * 0.5);

        if (_clear) {
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
                repath_t = flee_from(Player.x, Player.y)
                    ? round(0.5 * tps)
                    : round(0.2 * tps);
            }

            // Fallback anti-bodyblock
            if (!on_path && _pd < sight_radius * 1.5) {
                var _away = point_direction(Player.x, Player.y, x, y);
                var _offs = [0, 45, -45, 90, -90];

                panic = step_toward(_away + panic_off, flee_spd * VEL_MODIFIER);

                for (var _k = 0; _k < 5 && !panic; _k++) {
                    if (_offs[_k] == panic_off) continue;

                    if (step_toward(_away + _offs[_k], flee_spd * VEL_MODIFIER)) {
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
enemy_separation(16, 2, 4, true, Clown);