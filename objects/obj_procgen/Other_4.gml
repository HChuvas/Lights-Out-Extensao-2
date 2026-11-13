var _saved = pg_get_save(procgen_floor());
if (!is_undefined(_saved)) cfg.seed = _saved.seed;

plan = undefined;
for (var _try = 0; _try < 5 && is_undefined(plan); _try++) {
    plan = procgen_generate(cfg);
    if (is_undefined(plan)) cfg.seed = -1;
}
if (is_undefined(plan)) {
    show_debug_message("Não foi possível gerar um andar válido");
    exit;
}

// se caiu num fallback de seed, o save não vale mais
if (!is_undefined(_saved) && plan.seed != _saved.seed) _saved = undefined;
var _arrive_goal = (variable_global_exists("pg_arrive") && global.pg_arrive == "goal");

show_debug_message("andar " + string(cfg.floor_n) + " | " + string(cfg.min_rooms) + " salas pedidas");
show_debug_message("procgen: seed=" + string(plan.seed) + " salas=" + string(array_length(plan.rooms)));

// prédio centralizado na room
ox = ((room_width  div cfg.cell) - cfg.cols) div 2;
oy = ((room_height div cfg.cell) - cfg.rows) div 2;

// tiles e colisão
procgen_apply(plan, cfg, ox, oy);
// móveis atrás das instâncias
if (layer_exists("Decor")) layer_depth("Decor", 350);
plan.ox = ox;
plan.oy = oy;
procgen_verify_applied(plan, cfg, ox, oy);

// refaz a lista de tilemaps sólidos desta room
global.solid_maps = [];
var _names = ["Walls", "Collision"];
for (var _k = 0; _k < array_length(_names); _k++) {
    if (layer_exists(_names[_k])) {
        var _map = layer_tilemap_get_id(_names[_k]);
        if (_map != -1) array_push(global.solid_maps, _map);
    }
}

// pathfinding dos obj_chaser
if (instance_exists(obj_manager) && obj_manager.cell_size == cfg.cell) {
    procgen_sync_mp_grid(plan, cfg, ox, oy, obj_manager.map_grid);
    obj_manager.patrol_x1 = ox * cfg.cell;
    obj_manager.patrol_y1 = oy * cfg.cell;
    obj_manager.patrol_x2 = (ox + cfg.cols) * cfg.cell;
    obj_manager.patrol_y2 = (oy + cfg.rows) * cfg.cell;
}

// posiciona o Player na escada de onde ele veio
var _from = _arrive_goal ? plan.goal : plan.start;
var _in = procgen_cell_to_px(_from.cx, _from.cy, cfg, ox, oy);
if (!instance_exists(Player)) instance_create_layer(_in[0], _in[1], "Instances", Player);
Player.x = _in[0];
Player.y = _in[1];

// saída na sala mais distante
var _out = procgen_cell_to_px(plan.goal.cx, plan.goal.cy, cfg, ox, oy);
// escada de subida
instance_create_layer(_out[0] - 12, _out[1] - 12, "Instances", obj_stage_switch, {
    sprite_index: spr_stairs_up,
    x_pos: cfg.exit_x, y_pos: cfg.exit_y,
    room_name: cfg.exit_room,
    next_floor: cfg.next_floor,
    arrive: "start"
});

// escada para o andar de baixo
if (cfg.floor_n > 1) {
    var _dn = procgen_cell_to_px(plan.start.cx, plan.start.cy, cfg, ox, oy);
    instance_create_layer(_dn[0] - 12, _dn[1] - 12, "Instances", obj_stage_switch, {
        sprite_index: spr_stairs_down,
        x_pos: -1, y_pos: -1,
        room_name: r_procedural,
        next_floor: cfg.floor_n - 1,
        arrive: "goal"
    });
}

// inimigos
var _spawn_rooms = [];
for (var _min = 2; _min >= 1 && array_length(_spawn_rooms) == 0; _min--) {
    for (var _i = 0; _i < array_length(plan.rooms); _i++) {
        var _rm = plan.rooms[_i];
        // área da escada segura quando volta
        if (_rm.dist >= _min && !(_arrive_goal && _rm == plan.goal)) array_push(_spawn_rooms, _rm);
    }
}
if (!is_undefined(_saved)) {
    // cada inimigo volta onde estava
    for (var _e = 0; _e < array_length(_saved.enemies); _e++) {
        var _se = _saved.enemies[_e];
        var _inst = instance_create_layer(_se.x, _se.y, "Instances", _se.obj);
        var _fits = false;
        with (_inst) _fits = enemy_unstick();
        // luzes acesas: são só objetos parados, então ficam exatamente onde estavam
        // luzes apagadas: se está colado na escada onde o jogador chegou, nasce em outro lugar
        var _too_near = (pg_phase() >= 1 && point_distance(_inst.x, _inst.y, Player.x, Player.y) < 80);
        if (!_fits || _too_near) {
            instance_destroy(_inst);
            if (array_length(_spawn_rooms) > 0) procgen_spawn_enemy(_se.obj, plan, cfg, ox, oy, _spawn_rooms);
        }
    }
} else if (array_length(_spawn_rooms) > 0) {
    // quantidade definida por andar no cfg
    var _n_chasers = irandom_range(cfg.chasers[0], cfg.chasers[1]);
    var _n_clowns  = irandom_range(cfg.clowns[0],  cfg.clowns[1]);

    var _types = [];
    repeat (_n_chasers) array_push(_types, obj_chaser);
    repeat (_n_clowns)  array_push(_types, Clown);

    for (var _e = 0; _e < array_length(_types); _e++) {
        procgen_spawn_enemy(_types[_e], plan, cfg, ox, oy, _spawn_rooms);
    }
}

procgen_spawn_mimics(plan, cfg, ox, oy, irandom_range(cfg.mimics[0], cfg.mimics[1]), is_undefined(_saved) ? undefined : _saved.mimics);

// monstro do armário
procgen_spawn_wardrobes(plan, cfg, ox, oy, irandom_range(cfg.wardrobes[0], cfg.wardrobes[1]), is_undefined(_saved) ? undefined : _saved.wardrobes);

// teias e balões só existem depois que as luzes apagam (hazards = true)
// as aranhas já nascem desde o começo (viram novelo com as luzes acesas)
hazards = false;
if (!is_undefined(_saved)) {
    if (variable_struct_exists(_saved, "hazards") && _saved.hazards) {
        hazards = true;
        for (var _w = 0; _w < array_length(_saved.webs); _w++) {
            instance_create_layer(_saved.webs[_w].x, _saved.webs[_w].y, "Instances", obj_spider_web);
        }
    }
} else if (pg_phase() >= 1) {
    // andar novo com as luzes apagadas: teia e aranha como sempre
    hazards = true;
    var _webs = procgen_spawn_webs(plan, cfg, ox, oy, irandom_range(cfg.webs[0], cfg.webs[1]));
    procgen_spawn_spiders(irandom_range(cfg.spiders[0], cfg.spiders[1]), _webs);
} else if (array_length(_spawn_rooms) > 0) {
    // luzes acesas: mesma quantidade de aranhas de antes, mas sem teia
    var _n_webs = irandom_range(cfg.webs[0], cfg.webs[1]);
    var _n_spi  = min(irandom_range(cfg.spiders[0], cfg.spiders[1]), _n_webs);
    repeat (_n_spi) procgen_spawn_enemy(obj_spider, plan, cfg, ox, oy, _spawn_rooms);
}

// luzes acesas: os monstros são só objetos (viram monstros quando a criança pega o lanche)
if (pg_phase() == 0) pg_enemies_to_decoys();

// balões
if (!is_undefined(_saved)) {
    if (hazards) {
        for (var _b = 0; _b < array_length(_saved.balloons); _b++) {
            instance_create_layer(_saved.balloons[_b].x, _saved.balloons[_b].y, "Instances", Balloon);
        }
    }
} else if (pg_phase() >= 1) {
    procgen_spawn_balloons(plan, cfg, ox, oy, irandom_range(cfg.balloons[0], cfg.balloons[1]));
}

// andar salvo antes do apagão e visitado agora: teias e balões aparecem agora
if (!is_undefined(_saved) && !hazards && pg_phase() >= 1) {
    var _spots = [];
    with (obj_spider) array_push(_spots, { x: x, y: y });
    pg_spawn_hazards(plan, cfg, ox, oy, _spots);
}

// itens espalhados
if (!instance_exists(obj_inventory)) instance_create_layer(0, 0, "Instances", obj_inventory);

if (!is_undefined(_saved)) {
    // andar já visitado
    for (var _d = 0; _d < array_length(_saved.items); _d++) {
        var _si = _saved.items[_d];
        var _it = instance_create_layer(_si.x, _si.y, "Instances", _si.obj);
        _it.depth = _si.depth;
        _it._name = _si.name;
        _it._quantity = _si.quantity;
        _it._consumed = _si.consumed;
        _it._dropped = _si.dropped;
    }
    // lanche do objetivo ainda no lugar
    if (pg_phase() == 0 && variable_struct_exists(_saved, "foods")) {
        for (var _fd = 0; _fd < array_length(_saved.foods); _fd++) {
            var _sn = instance_create_layer(_saved.foods[_fd].x, _saved.foods[_fd].y, "Instances", obj_snack);
            _sn.depth = _saved.foods[_fd].depth;
        }
    }
} else {
    // sorteia de 1 a 2 itens do andar 
    var _pool = [];
    for (var _d = 0; _d < array_length(cfg.items); _d++) {
        var _def = cfg.items[_d];
        repeat (_def.count) array_push(_pool, _def.obj);
    }
    procgen_shuffle(_pool);
    var _n_items = clamp(irandom_range(cfg.items_per_floor[0], cfg.items_per_floor[1]), 0, array_length(_pool));
    var _drops = [];
    for (var _d = 0; _d < _n_items; _d++) array_push(_drops, _pool[_d]);

    // itens em cima de móveis
    var _spots = procgen_item_spots(plan, cfg, ox, oy, _drops);

    // lanche do objetivo: só no 1º andar, na sala mais longe de onde o jogador chega
    if (cfg.floor_n == 1 && pg_phase() == 0) {
        var _snack = procgen_snack_spot(plan, cfg, ox, oy, obj_snack);
        if (!is_undefined(_snack)) array_push(_spots, _snack);
    }
    for (var _d = 0; _d < array_length(_spots); _d++) {
        var _s = _spots[_d];
        var _spr = object_get_sprite(_s.obj);
        var _ix, _iy;

        if (_s.floor) {
            // no chão, centraliza na célula
            _ix = _s.x - sprite_get_width(_spr) div 2 + sprite_get_xoffset(_spr);
            _iy = _s.y - sprite_get_height(_spr) div 2 + sprite_get_yoffset(_spr);
        } else {
            // no móvel, a base do sprite fica apoiada na superfície
            _ix = _s.x - sprite_get_width(_spr) div 2 + sprite_get_xoffset(_spr);
            _iy = _s.y - sprite_get_height(_spr) + sprite_get_yoffset(_spr);
        }

        var _inst = instance_create_layer(_ix, _iy, "Instances", _s.obj);
        if (!_s.floor) _inst.depth = _s.depth; // desenha por cima do móvel
    }
}

// debug
if (variable_global_exists("pg_debug_snack") && global.pg_debug_snack) {
    global.pg_debug_snack = false;
    pg_debug_place_at_snack();
}