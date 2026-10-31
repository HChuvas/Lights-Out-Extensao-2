plan = undefined;
for (var _try = 0; _try < 5 && is_undefined(plan); _try++) {
    plan = procgen_generate(cfg);
    if (is_undefined(plan)) cfg.seed = -1;
}
if (is_undefined(plan)) {
    show_debug_message("Não foi possível gerar um andar válido");
    exit;
}
show_debug_message("andar " + string(cfg.floor_n) + " | " + string(cfg.min_rooms) + " salas pedidas");
show_debug_message("procgen: seed=" + string(plan.seed) + " salas=" + string(array_length(plan.rooms)));

// prédio centralizado na room
ox = ((room_width  div cfg.cell) - cfg.cols) div 2;
oy = ((room_height div cfg.cell) - cfg.rows) div 2;

// tiles e colisão
procgen_apply(plan, cfg, ox, oy);
// móveis atrás dos instances: o palhaço (sprite alto) não pode ficar escondido atrás de móvel
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

// posiciona o Player no centro da sala inicial
var _in = procgen_cell_to_px(plan.start.cx, plan.start.cy, cfg, ox, oy);
if (!instance_exists(Player)) instance_create_layer(_in[0], _in[1], "Instances", Player);
Player.x = _in[0];
Player.y = _in[1];

// saída na sala mais distante
var _out = procgen_cell_to_px(plan.goal.cx, plan.goal.cy, cfg, ox, oy);
instance_create_layer(_out[0], _out[1], "Instances", obj_stage_switch, {
    x_pos: cfg.exit_x, y_pos: cfg.exit_y,
    room_name: cfg.exit_room,
    next_floor: cfg.next_floor
});

// inimigos
var _spawn_rooms = [];
for (var _i = 0; _i < array_length(plan.rooms); _i++) if (plan.rooms[_i].dist >= 2) array_push(_spawn_rooms, plan.rooms[_i]);
if (array_length(_spawn_rooms) == 0) {
    for (var _i = 0; _i < array_length(plan.rooms); _i++) if (plan.rooms[_i].dist >= 1) array_push(_spawn_rooms, plan.rooms[_i]);
}
if (array_length(_spawn_rooms) > 0) {
    // quantidade definida por andar no cfg
    var _n_chasers = cfg.chasers;
    var _n_clowns  = cfg.clowns;

    var _types = [];
    repeat (_n_chasers) array_push(_types, obj_chaser);
    repeat (_n_clowns)  array_push(_types, Clown);

    for (var _e = 0; _e < array_length(_types); _e++) {
        procgen_spawn_enemy(_types[_e], plan, cfg, ox, oy, _spawn_rooms);
    }
}

// itens espalhados
if (!instance_exists(obj_inventory)) instance_create_layer(0, 0, "Instances", obj_inventory);

var _drops = [];
for (var _d = 0; _d < array_length(cfg.items); _d++) {
    var _def = cfg.items[_d];
    repeat (_def.count) array_push(_drops, _def.obj);
}

var _cells = procgen_item_cells(plan, array_length(_drops));
for (var _d = 0; _d < array_length(_cells); _d++) {
    var _ip = procgen_cell_to_px(_cells[_d][0], _cells[_d][1], cfg, ox, oy);

    // compensa a origem do sprite para o item ficar centralizado na célula
    var _spr = object_get_sprite(_drops[_d]);
    var _ix = _ip[0] - sprite_get_width(_spr) div 2 + sprite_get_xoffset(_spr);
    var _iy = _ip[1] - sprite_get_height(_spr) div 2 + sprite_get_yoffset(_spr);

    instance_create_layer(_ix, _iy, "Instances", _drops[_d]);
}
