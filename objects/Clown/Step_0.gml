// Checagem inicial
if (!variable_global_exists("cell") || !variable_global_exists("solid_maps")) exit;

// Inicializa a grid
if (!ready) {
    cell = global.cell;
    cols = ceil(room_width / cell);
    rows = ceil(room_height / cell);

    if (!variable_global_exists("grid_safe") || !variable_global_exists("grid_room") || global.grid_room != room) {
        build_safe_grid();
    }
    build_reachable();
    ready = true;
}

// Atualizações por frame
unstick();
arm_cooldown = max(0, arm_cooldown - 1);
follow_path();
watchdog();

// Sistema de visão
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

            var _pa = free_point(balloon_min_dist, true)
                   ?? free_point(balloon_min_dist)
                   ?? free_point(balloon_min_dist * 0.5);

            if (_pa != undefined && go_to(_pa.x, _pa.y, arm_spd)) {
                state = CLOWN.ARM;
            } else {
                arm_cooldown = tps;
            }
        }
        else if (idle_timer <= 0) {
            idle_timer = 2 * tps;

            if (irandom(99) < 40) {
                var _pp = free_point();
                if (_pp != undefined && go_to(_pp.x, _pp.y, patrol_spd)) {
                    state = CLOWN.PATROL;
                }
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

            // só replaneja se não tem rota, ou se a rota passa na frente do player
            // (compromisso mínimo de 0,5 s com o destino pra não ficar trocando de ideia)
            if (repath_t <= 0 && _pd < sight_radius * 1.5 && (!on_path || path_near_player())) {
                repath_t = flee_from(Player.x, Player.y) ? round(0.5 * tps) : round(0.2 * tps);
            }

            // Fallback anti-bodyblock: mantém a direção que funcionou por último
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

// Animação
update_anim();
