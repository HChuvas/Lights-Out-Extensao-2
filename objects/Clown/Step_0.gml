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
    update_anim(); // atualiza o sprite antes do exit
    exit;
}

// Máquina de estados
switch (state) {
    
    case CLOWN.IDLE:
        idle_timer--;

        if (arm_cooldown <= 0 && instance_number(Balloon) < max_balloons) {
            
            var _pa = free_point(balloon_min_dist, true) ?? free_point(balloon_min_dist);

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

        if (_see) flee_timer = max(flee_timer, 2 * tps);

        if (!on_path && repath_t <= 0 && instance_exists(Player)
            && point_distance(x, y, Player.x, Player.y) < sight_radius * 1.5) {
            if (!flee_from(Player.x, Player.y)) {
                repath_t = 0.25 * tps;
            }
        }

        if (flee_timer <= 0) {
            on_path = false;
            idle_timer = 2 * tps;
            state = CLOWN.IDLE;
        }
    break;
}

// Animação
update_anim();