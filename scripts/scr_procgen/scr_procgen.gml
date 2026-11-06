// 1 - Grid do andar (ds_grid, em tiles de 16px)
// 2 - BSP iterativo até atingir o tamanho mínimo de sala OU o nº de salas sorteado
// 3 - Eleger as salas (regras de cômodo) + entrada e saída
// 4 - Portas (conexão entre salas)
// 5 - Preset de decoração por cômodo
// 6 - Aplicação nos tilemaps / mp_grid / instâncias


enum PG_TILE  { WALL, FLOOR, DOOR } // valores do ds_grid
enum PG_ROOM { LIVING, KITCHEN, BATHROOM, STORAGE, OFFICE, LAUNDRY } // cômodos
#macro PG_FACE 2 // linhas de painel 
enum PG_AT { TOP, SIDE, BOTTOM, CORNER, CENTER, ANY, RUN, WALL } // onde uma regra do preset coloca o objeto


// ----------------------------------------------------------------------------
//  CONFIGURAÇÃO
// ----------------------------------------------------------------------------
function procgen_config() {
    var _f = procgen_floor();
    var _last = (_f >= 3);
    var _rooms = [[3, 3], [4, 5], [5, 6]][_f - 1]; // salas por andar
    var _size  = [[28, 20], [36, 24], [44, 28]][_f - 1]; // tamanho do andar 

    // tapetes
    var _rug_a = [243, 244, 245, 265, 266, 267, 287, 288, 289];
    var _rug_b = [250, 251, 252, 272, 273, 274, 294, 295, 296];
    var _rug_c = [257, 258, 259, 279, 280, 281, 301, 302, 303];

    return {
        floor_n: _f,
        // tamanho do andar
        cols: _size[0],
        rows: _size[1],
        cell: 16,

        // BSP
        min_room: 9, // lado mínimo da sala
        min_rooms: _rooms[0], // andar 1: 3, andar 2: 4-5, andar 3: 5-6
        max_rooms: _rooms[1],
        floor_last: 3, // último andar
        split_jitter: 0.2, // sempre divide no meio e varia até 20% do lado
        loop_chance: 0.25, // chance de abrir portas extras
        door_width: 2, // largura da porta

        // geração
        seed: -1, // aleatória
        max_attempts: 20,

        // tiles
        tile_collision: 1,

        // Piso
        // (sala, cozinha, banheiro, despensa, escritório, lavanderia)
        floors: [[266, 280], [266, 280], [266, 280], [266, 280], [266, 280], [266, 280]],

        // Paredes
        wall_h: [117, 118, 119],   // horizontal
        wall_v: [72, 94, 116],     // vertical
        wall_corner: { tl: 73, tr: 74, bl: 117, br: 119 },
        wall_block: 75,            // cruzamentos
        face_top: [185, 186],     
        face_bot: [207, 208],    
        door_top: [112, 113],
        door_bot: [134, 135],   
        tileset_floor: ts_modern_pack,
        tileset_walls: ts_modern_pack,

        // Tapetes por cômodo
        rug_scale: [0.6, 0.5, 0.5, 0.5, 0.55, 0.5], // tamanho do tapete por cômodo
        rugs: [
            [{ spr: spr_furniture_09 }, _rug_a], // sala
            [], // cozinha 
            [_rug_c], // banheiro
            [], // despensa
            [_rug_a], // escritório
            [] // lavanderia
        ],

        // layers
        layer_floor: "Floor",
        layer_wall: "Walls",
        layer_collision: "Collision",
        layer_decor: "Decor", // só limpa o que foi pintado no editor
        tileset_rugs: ts_modern_pack,
        depth_rugs: 590, 
        depth_props: 350,
        depth_tops: 345,
        depth_frames: 250, // batente da porta

        decor_blocks: true,

        // saída do andar
        exit_room: _last ? r_starting_room : r_procedural, // último andar
        next_floor: _last ? 1 : _f + 1,
        exit_x: _last ? 347 : -1,
        exit_y: _last ? 544 : -1,

        // inimigos
        chasers: [[1, 1], [1, 2], [2, 2]][_f - 1],
        clowns:  [[0, 1], [0, 1], [1, 1]][_f - 1],
        mimics:  [[0, 1], [1, 1], [1, 2]][_f - 1],
        balloons: [[1, 2], [2, 3], [2, 4]][_f - 1],

        // itens espalhados
        items: [
            { obj: obj_flashlight, name: "flashlight", count: 1, unique: true  },
            { obj: obj_water_cup,  name: "water_cup",  count: 1, unique: false }
        ]
    };
}


// ----------------------------------------------------------------------------
//  MÓVEIS
// ----------------------------------------------------------------------------
function procgen_props() {
    var _d = {
        // cozinha
        fridge:    { spr: spr_furniture_13 },
        stove:     { spr: [spr_furniture_19, spr_furniture_06] },
        sink:      { spr: spr_furniture_17 },
        counter:   { spr: [spr_furniture_61, spr_furniture_62, spr_furniture_63], top_y: 11,
                     tops: [spr_furniture_04, spr_furniture_05, spr_furniture_20, spr_furniture_21, spr_furniture_29, spr_furniture_31, spr_furniture_36, spr_furniture_42] },
        table:     { spr: [spr_furniture_56, spr_furniture_62, spr_furniture_63], top_y: 11,
                     tops: [spr_furniture_20, spr_furniture_21, spr_furniture_29, spr_furniture_36, spr_furniture_42, spr_furniture_46] },
        chair:     { spr: spr_furniture_67, spr_l: spr_furniture_67, spr_r: spr_furniture_70, fh: 1, chair: true },
        chair_up:  { spr: spr_furniture_68, fh: 1, chair: true },
        // sala
        tv:        { spr: spr_furniture_53 },
        fireplace: { spr: spr_furniture_27 },
        sofa:      { spr: spr_furniture_71 },
        armchair:  { spr: spr_furniture_65, spr_l: spr_furniture_65, spr_r: spr_furniture_66 },
        sidetable: { spr: [spr_furniture_10, spr_furniture_80], top_y: 8, tops: [spr_furniture_01, spr_furniture_02, spr_furniture_46] },
        plant:     { spr: spr_furniture_38 },
        planter:   { spr: spr_furniture_00 },
        // escritório, despensa e lavanderia
        desk:      { spr: [spr_furniture_43, spr_furniture_58] },
        cabinet:   { spr: [spr_furniture_07, spr_furniture_11, spr_furniture_81], top_y: 8,
                     tops: [spr_furniture_01, spr_furniture_02, spr_furniture_36, spr_furniture_46, spr_furniture_48] },
        wardrobe:  { spr: spr_furniture_83 },
        bench:     { spr: spr_furniture_12 },
        box:       { spr: spr_furniture_32 },
        basket:    { spr: spr_furniture_48 },
        bin:       { spr: spr_furniture_54 },
        // banheiro
        toilet:    { spr: [spr_furniture_15, spr_furniture_16] },
        tub:       { spr: [spr_furniture_49, spr_furniture_50] },
        // decoração de parede
        picture:   { spr: [spr_furniture_08, spr_furniture_14] },
        note:      { spr: spr_furniture_45 },
        towel:     { spr: spr_furniture_59 }
    };
    _d.desk.seat = _d.chair_up; // cadeira embaixo da mesa de trabalho
    return _d;
}


// ----------------------------------------------------------------------------
//  PRESETS
// ----------------------------------------------------------------------------
function procgen_presets() {
    var _p = array_create(6, []);
    _p[PG_ROOM.LIVING] = [
        { at: PG_AT.RUN,    runs: [["cabinet", "tv", "cabinet"], ["fireplace", "cabinet", "planter"], ["planter", "tv", "sidetable"]] },
        { at: PG_AT.CENTER, prop: "sofa",      lo: 1, hi: 1 },
        { at: PG_AT.SIDE,   prop: "armchair",  lo: 1, hi: 2 },
        { at: PG_AT.SIDE,   prop: "sidetable", lo: 0, hi: 1 },
        { at: PG_AT.CORNER, prop: "plant",     lo: 1, hi: 2 },
        { at: PG_AT.WALL,   prop: "picture",   lo: 2, hi: 3 }
    ];
    _p[PG_ROOM.KITCHEN] = [
        { at: PG_AT.RUN,    runs: [["fridge", "stove", "sink", "counter", "counter"], ["counter", "stove", "sink", "fridge", "counter"]] },
        { at: PG_AT.CENTER, prop: "table",     lo: 1, hi: 1, flank: "chair" },
        { at: PG_AT.SIDE,   prop: "cabinet",   lo: 0, hi: 1 },
        { at: PG_AT.CORNER, prop: "bin",       lo: 1, hi: 1 },
        { at: PG_AT.CORNER, prop: "plant",     lo: 0, hi: 1 },
        { at: PG_AT.WALL,   prop: "picture",   lo: 1, hi: 2 },
        { at: PG_AT.WALL,   prop: "note",      lo: 0, hi: 1 }
    ];
    _p[PG_ROOM.BATHROOM] = [
        { at: PG_AT.RUN,    runs: [["toilet", "sink", "tub"], ["tub", "toilet", "sink"], ["sink", "toilet", "tub"]] },
        { at: PG_AT.CORNER, prop: "bin",       lo: 1, hi: 1 },
        { at: PG_AT.CORNER, prop: "plant",     lo: 0, hi: 1 },
        { at: PG_AT.WALL,   prop: "towel",     lo: 1, hi: 1 },
        { at: PG_AT.WALL,   prop: "picture",   lo: 0, hi: 1 }
    ];
    _p[PG_ROOM.STORAGE] = [
        { at: PG_AT.RUN,    runs: [["wardrobe", "cabinet", "cabinet", "bench"], ["cabinet", "wardrobe", "wardrobe"]] },
        { at: PG_AT.SIDE,   prop: "cabinet",   lo: 1, hi: 2 },
        { at: PG_AT.SIDE,   prop: "wardrobe",  lo: 0, hi: 1 },
        { at: PG_AT.SIDE,   prop: "box",       lo: 2, hi: 3 },
        { at: PG_AT.CORNER, prop: "box",       lo: 1, hi: 2 },
        { at: PG_AT.CORNER, prop: "basket",    lo: 0, hi: 1 },
        { at: PG_AT.WALL,   prop: "note",      lo: 1, hi: 1 }
    ];
    _p[PG_ROOM.OFFICE] = [
        { at: PG_AT.RUN,    runs: [["cabinet", "desk", "wardrobe"], ["desk", "cabinet", "cabinet"], ["wardrobe", "desk", "cabinet"]] },
        { at: PG_AT.SIDE,   prop: "cabinet",   lo: 1, hi: 2 },
        { at: PG_AT.CORNER, prop: "plant",     lo: 1, hi: 2 },
        { at: PG_AT.CORNER, prop: "bin",       lo: 1, hi: 1 },
        { at: PG_AT.WALL,   prop: "picture",   lo: 1, hi: 2 },
        { at: PG_AT.WALL,   prop: "note",      lo: 1, hi: 2 }
    ];
    _p[PG_ROOM.LAUNDRY] = [
        { at: PG_AT.RUN,    runs: [["sink", "counter", "cabinet"], ["cabinet", "sink", "counter"]] }, // bancada de dobrar roupa na parede
        { at: PG_AT.CORNER, prop: "basket",    lo: 2, hi: 3 },
        { at: PG_AT.CORNER, prop: "bin",       lo: 0, hi: 1 },
        { at: PG_AT.SIDE,   prop: "wardrobe",  lo: 0, hi: 1 },
        { at: PG_AT.WALL,   prop: "towel",     lo: 1, hi: 1 },
        { at: PG_AT.WALL,   prop: "note",      lo: 0, hi: 1 }
    ];
    return _p;
}

// andar atual (1 a 3)
function procgen_floor() {
    if (!variable_global_exists("pg_floor")) global.pg_floor = 1;
    return clamp(global.pg_floor, 1, 3);
}


// ============================================================================
//  ENTRADA PRINCIPAL
// ============================================================================
function procgen_generate(_cfg) {
    var _seed = _cfg.seed;
    if (_seed < 0) {
        randomize();
        _seed = irandom(999999999);
    }

    var _plan = undefined;
    for (var _a = 0; _a < _cfg.max_attempts; _a++) {
        random_set_seed(_seed + _a);
        _plan = procgen_try(_cfg);
        if (!is_undefined(_plan)) {
            _plan.seed = _seed;
            _plan.attempt = _a;
            break;
        }
    }

    randomize();
    return _plan;
}

function procgen_try(_cfg) {
    // BSP
    var _bsp = procgen_bsp(_cfg);
    var _rooms = _bsp.leaves;
	if (array_length(_rooms) < _cfg.min_rooms) return undefined;
    for (var _i = 0; _i < array_length(_rooms); _i++) {
        var _r = _rooms[_i];
        _r.idx   = _i;
        _r.links = []; // índices das salas ligadas por porta
        _r.type  = -1;
        _r.cx    = _r.x + _r.w div 2; // célula central
        _r.cy    = (_r.y + 1 + PG_FACE + _r.y + _r.h - 2) div 2; // centro do chão
        _r.area  = (_r.w - 2) * (_r.h - 2); // área interna 
        _r.dist  = -1; // distância até a entrada
        _r.focus_x = -1; // coluna da TV/lareira
        _r.placed  = {}; // móveis colocados na sala
    }

    var _plan = {
        cols: _cfg.cols, rows: _cfg.rows,
        grid:  ds_grid_create(_cfg.cols, _cfg.rows),
        decor: ds_grid_create(_cfg.cols, _cfg.rows),
        rug:   ds_grid_create(_cfg.cols, _cfg.rows),
        face:  ds_grid_create(_cfg.cols, _cfg.rows),
        frames: [], // batentes de porta
        map_frames: -1, // tilemap dos batentes
        lids: {}, lid_cells: [], // topo da parede por cima das portas horizontais
        strips: [],
        root: _bsp.root, inner: _bsp.inner, rooms: _rooms,
        doors: [],
        start: undefined, goal: undefined, // entrada e saída 
        seed: 0, attempt: 0,
        ox: 0, oy: 0, cell: _cfg.cell,
        stools: [], // células das cadeiras
		props: [],
		wall_used: {},
        mismatch: [],
        walk: [] // células que o jogador realmente alcança
    };
    ds_grid_clear(_plan.decor, 0);
    ds_grid_clear(_plan.face, 0);
    _plan.stools = [];
    _plan.props = [];
    ds_grid_clear(_plan.rug, 0);

    procgen_carve(_plan); // paredes e chão
    if (!procgen_proportions_ok(_plan)) { procgen_destroy(_plan); return undefined; }
    if (!procgen_connect(_plan, _cfg)) { procgen_destroy(_plan); return undefined; }  // portas que ligam a casa
    procgen_assign_roles(_plan);
    procgen_connect_loops(_plan, _cfg); // portas extras
    if (!procgen_validate(_plan)) { procgen_destroy(_plan); return undefined; }

    // decoração
    var _ok = false;
    for (var _t = 0; _t < 12 && !_ok; _t++) {
        ds_grid_clear(_plan.decor, 0);
        ds_grid_clear(_plan.rug, 0);
        procgen_decorate(_plan, _cfg);
        _ok = procgen_validate_decor(_plan) && procgen_has_required(_plan);
    }
    if (!_ok) { procgen_destroy(_plan); return undefined; }
    return _plan;
}


function procgen_destroy(_plan) {
    if (is_undefined(_plan)) return;
    if (ds_exists(_plan.grid,  ds_type_grid)) ds_grid_destroy(_plan.grid);
    if (ds_exists(_plan.decor, ds_type_grid)) ds_grid_destroy(_plan.decor);
    if (ds_exists(_plan.rug,   ds_type_grid)) ds_grid_destroy(_plan.rug);
    if (ds_exists(_plan.face,  ds_type_grid)) ds_grid_destroy(_plan.face);
}


// ============================================================================
// BSP ITERATIVO
// ============================================================================
function procgen_bsp(_cfg) {
    var _root = { x: 0, y: 0, w: _cfg.cols, h: _cfg.rows, left: undefined, right: undefined };
    var _leaves = [_root];
    var _inner = []; // nós internos
    var _target = irandom_range(_cfg.min_rooms, _cfg.max_rooms); // número de salas do andar

    while (array_length(_leaves) < _target) {
        var _pick = -1, _best = -1;
        for (var _i = 0; _i < array_length(_leaves); _i++) {
            var _n = _leaves[_i];
            if (!procgen_can_split(_n, _cfg.min_room)) continue;
            var _area = _n.w * _n.h;
            if (_area > _best) { _best = _area; _pick = _i; }
        }
        if (_pick == -1) break;

        var _node = _leaves[_pick];
        procgen_split(_node, _cfg);
        array_delete(_leaves, _pick, 1);
        array_push(_leaves, _node.left, _node.right);
        array_push(_inner, _node);
    }
    return { root: _root, leaves: _leaves, inner: _inner };
}

// Uma folha com lado L gera duas de tamanhos a e b com a + b = L + 1
function procgen_can_split(_n, _min) {
    return (_n.w >= 2 * _min - 1) || (_n.h >= 2 * _min - 1);
}

function procgen_split(_n, _cfg) {
    var _min = _cfg.min_room;
    var _can_v = _n.w >= 2 * _min - 1; // corte vertical divide a largura
    var _can_h = _n.h >= 2 * _min - 1;

    var _vertical;
    if (_can_v && _can_h) {
        if (_n.w > _n.h * 1.25)      _vertical = true;
        else if (_n.h > _n.w * 1.25) _vertical = false;
        else                         _vertical = (irandom(1) == 1);
    } else {
        _vertical = _can_v;
    }

    if (_vertical) {
        var _sx = procgen_split_pos(_n.x, _n.w, _cfg);
        _n.left  = { x: _n.x, y: _n.y, w: _sx - _n.x + 1,    h: _n.h, left: undefined, right: undefined };
        _n.right = { x: _sx,  y: _n.y, w: _n.x + _n.w - _sx, h: _n.h, left: undefined, right: undefined };
    } else {
        var _sy = procgen_split_pos(_n.y, _n.h, _cfg);
        _n.left  = { x: _n.x, y: _n.y, w: _n.w, h: _sy - _n.y + 1,    left: undefined, right: undefined };
        _n.right = { x: _n.x, y: _sy,  w: _n.w, h: _n.y + _n.h - _sy, left: undefined, right: undefined };
    }
}

// Posição absoluta da linha de corte
function procgen_split_pos(_start, _len, _cfg) {
    var _min = _cfg.min_room;
    var _lo  = _start + _min - 1;
    var _hi  = _start + _len - _min;
    var _mid = _start + (_len - 1) div 2;
    var _j   = floor(_len * _cfg.split_jitter);
    return clamp(_mid + irandom_range(-_j, _j), _lo, _hi);
}

function procgen_leaves_of(_node) {
    var _out = [];
    var _stack = [_node];
    while (array_length(_stack) > 0) {
        var _n = array_pop(_stack);
        if (is_undefined(_n.left)) array_push(_out, _n);
        else { array_push(_stack, _n.right); array_push(_stack, _n.left); }
    }
    return _out;
}


// ============================================================================
//  PAREDES + CHÃO
// ============================================================================
function procgen_carve(_plan) {
    ds_grid_clear(_plan.grid, PG_TILE.WALL);
    for (var _i = 0; _i < array_length(_plan.rooms); _i++) {
        var _r = _plan.rooms[_i];
        // o chão começa depois do painel da parede de cima
        ds_grid_set_region(_plan.grid, _r.x + 1, _r.y + 1 + PG_FACE, _r.x + _r.w - 2, _r.y + _r.h - 2, PG_TILE.FLOOR);
        ds_grid_set_region(_plan.face, _r.x + 1, _r.y + 1, _r.x + _r.w - 2, _r.y + PG_FACE, 1);
    }
}


// ============================================================================
// PORTAS
// ============================================================================

function procgen_shared_wall(_a, _b) {
    var _ax2 = _a.x + _a.w - 1, _ay2 = _a.y + _a.h - 1;
    var _bx2 = _b.x + _b.w - 1, _by2 = _b.y + _b.h - 1;

    if (_ax2 == _b.x || _bx2 == _a.x) { // parede vertical
        var _ylo = max(_a.y, _b.y) + 1 + PG_FACE; // porta lateral não pode encostar no painel
        var _yhi = min(_ay2, _by2) - 1;
        if (_yhi >= _ylo) return { vertical: true, at: (_ax2 == _b.x) ? _b.x : _a.x, lo: _ylo, hi: _yhi };
    }
    if (_ay2 == _b.y || _by2 == _a.y) { // parede horizontal
        var _xlo = max(_a.x, _b.x) + 1;
        var _xhi = min(_ax2, _bx2) - 1;
        if (_xhi >= _xlo) return { vertical: false, at: (_ay2 == _b.y) ? _b.y : _a.y, lo: _xlo, hi: _xhi };
    }
    return undefined;
}

function procgen_door_near(_plan, _x, _y) {
    for (var _d = 0; _d < 4; _d++) {
        var _nx = _x + ((_d == 0) - (_d == 1));
        var _ny = _y + ((_d == 2) - (_d == 3));
        if (_nx < 0 || _ny < 0 || _nx >= _plan.cols || _ny >= _plan.rows) continue;
        if (ds_grid_get(_plan.grid, _nx, _ny) == PG_TILE.DOOR) return true;
    }
    return false;
}

function procgen_add_door(_plan, _a, _b, _w, _dw) {
    if (_w.hi - _w.lo + 1 < _dw) return false;
    var _len = _dw;
    var _p   = irandom_range(_w.lo, _w.hi - _len + 1);
    if (_w.hi - _w.lo + 1 >= _len + 2) _p = irandom_range(_w.lo + 1, _w.hi - _len);

    // confere todas as células da porta antes de abrir
    for (var _i = 0; _i < _len; _i++) {
        var _cx = _w.vertical ? _w.at : _p + _i;
        var _cy = _w.vertical ? _p + _i : _w.at;
        if (procgen_door_near(_plan, _cx, _cy)) return false; // não cola porta com porta
    }
    for (var _i = 0; _i < _len; _i++) {
        var _cx = _w.vertical ? _w.at : _p + _i;
        var _cy = _w.vertical ? _p + _i : _w.at;
        ds_grid_set(_plan.grid, _cx, _cy, PG_TILE.DOOR);

        if (!_w.vertical) { 
            variable_struct_set(_plan.lids, string(_cx) + "_" + string(_cy), true);
            array_push(_plan.lid_cells, [_cx, _cy]);
            for (var _k = 1; _k <= PG_FACE; _k++) {
                ds_grid_set(_plan.grid, _cx, _cy + _k, PG_TILE.DOOR);
                ds_grid_set(_plan.face, _cx, _cy + _k, 0);
            }
            var _side = (_i == 0) ? 0 : 1;
            array_push(_plan.frames, [_cx, _cy + 1, true, _side]);
            array_push(_plan.frames, [_cx, _cy + PG_FACE, false, _side]);
        }
    }

    array_push(_a.links, _b.idx);
    array_push(_b.links, _a.idx);
    array_push(_plan.doors, { x: _w.vertical ? _w.at : _p, y: _w.vertical ? _p : _w.at, a: _a.idx, b: _b.idx });
    return true;
}

function procgen_connect(_plan, _cfg) {
    // árvore geradora
    for (var _n = 0; _n < array_length(_plan.inner); _n++) {
        var _node = _plan.inner[_n];
        var _la = procgen_leaves_of(_node.left);
        var _lb = procgen_leaves_of(_node.right);

        var _cand = [];
        for (var _i = 0; _i < array_length(_la); _i++) {
            for (var _j = 0; _j < array_length(_lb); _j++) {
                var _w = procgen_shared_wall(_la[_i], _lb[_j]);
                if (!is_undefined(_w)) array_push(_cand, { a: _la[_i], b: _lb[_j], wall: _w });
            }
        }
        procgen_shuffle(_cand);

        var _ok = false;
        for (var _k = 0; _k < array_length(_cand) && !_ok; _k++) {
            _ok = procgen_add_door(_plan, _cand[_k].a, _cand[_k].b, _cand[_k].wall, _cfg.door_width);
        }
        if (!_ok) return false;
    }

    return true;
}

// portas extras
function procgen_connect_loops(_plan, _cfg) {
    var _rooms = _plan.rooms;
    for (var _i = 0; _i < array_length(_rooms); _i++) {
        for (var _j = _i + 1; _j < array_length(_rooms); _j++) {
            var _a = _rooms[_i], _b = _rooms[_j];
            if (procgen_in(_a.links, _j)) continue;
            if (_a.type == PG_ROOM.BATHROOM || _b.type == PG_ROOM.BATHROOM) continue;
            if (_a.type == PG_ROOM.STORAGE  || _b.type == PG_ROOM.STORAGE)  continue;
            if (random(1) >= _cfg.loop_chance) continue;
            var _ew = procgen_shared_wall(_a, _b);
            if (!is_undefined(_ew)) procgen_add_door(_plan, _a, _b, _ew, _cfg.door_width);
        }
    }
}

// salas com proporção de cômodo
function procgen_proportions_ok(_plan) {
    for (var _i = 0; _i < array_length(_plan.rooms); _i++) {
        var _r = _plan.rooms[_i];
        var _ratio = (_r.w - 2) / (_r.h - 2 - PG_FACE);
        if (_ratio > 2.5 || _ratio < 0.45) return false;
    }
    return true;
}


// ============================================================================
// SALAS
// ============================================================================
function procgen_assign_roles(_plan) {
    var _rooms = _plan.rooms;
    var _n = array_length(_rooms);

    var _edge = [];
    for (var _i = 0; _i < _n; _i++) {
        var _r = _rooms[_i];
        if (_r.x == 0 || _r.y == 0 || _r.x + _r.w == _plan.cols || _r.y + _r.h == _plan.rows) array_push(_edge, _r);
    }
    if (array_length(_edge) == 0) _edge = _rooms;
    var _start = _edge[irandom(array_length(_edge) - 1)];

    // distância em portas
    _start.dist = 0;
    var _q = [_start.idx], _head = 0;
    while (_head < array_length(_q)) {
        var _cur = _rooms[_q[_head++]];
        for (var _k = 0; _k < array_length(_cur.links); _k++) {
            var _nb = _rooms[_cur.links[_k]];
            if (_nb.dist == -1) { _nb.dist = _cur.dist + 1; array_push(_q, _nb.idx); }
        }
    }

    var _goal = _start;
    for (var _i = 0; _i < _n; _i++) if (_rooms[_i].dist > _goal.dist) _goal = _rooms[_i];

    _plan.start = _start;
    _plan.goal  = _goal;

    // sala inicial
    _start.type = PG_ROOM.LIVING;

    // cozinha
    var _kit = undefined;
    for (var _k = 0; _k < array_length(_start.links); _k++) {
        var _r = _rooms[_start.links[_k]];
        if (is_undefined(_kit) || _r.area > _kit.area) _kit = _r;
    }
    if (!is_undefined(_kit)) _kit.type = PG_ROOM.KITCHEN;

    // banheiro
    var _free = [];
    for (var _i = 0; _i < _n; _i++) if (_rooms[_i].type == -1) array_push(_free, _rooms[_i]);
    array_sort(_free, function(_a, _b) { return _a.area - _b.area; });
    var _bath = undefined;
    if (array_length(_free) > 0) {
        var _bi = -1; // banheiro sem saída
        for (var _i = 0; _i < array_length(_free); _i++) {
            if (array_length(_free[_i].links) == 1 && _free[_i] != _goal) { _bi = _i; break; }
        }
        if (_bi == -1) {
            for (var _i = 0; _i < array_length(_free); _i++) {
                if (_free[_i] != _goal) { _bi = _i; break; }
            }
        }
        if (_bi != -1) {
            _bath = _free[_bi];
            _bath.type = PG_ROOM.BATHROOM;
            array_delete(_free, _bi, 1);
        }
    }

    // o resto sorteia entre escritório, lavanderia e despensa
    var _kinds = [PG_ROOM.LAUNDRY, PG_ROOM.OFFICE, PG_ROOM.STORAGE];
    procgen_shuffle(_kinds);
    procgen_shuffle(_free);
    var _m = min(array_length(_free), array_length(_kinds));
    for (var _i = 0; _i < _m; _i++) _free[_i].type = _kinds[_i];

    // lavanderia perto da cozinha ou do banheiro
    for (var _i = 0; _i < _m; _i++) {
        if (_free[_i].type != PG_ROOM.LAUNDRY || procgen_wet(_free[_i], _kit, _bath)) continue;
        for (var _j = 0; _j < _m; _j++) {
            if (_j == _i || !procgen_wet(_free[_j], _kit, _bath)) continue;
            _free[_i].type = _free[_j].type;
            _free[_j].type = PG_ROOM.LAUNDRY;
            break;
        }
    }

    if (_goal.type == PG_ROOM.STORAGE) {
        _goal.type = PG_ROOM.OFFICE;
        for (var _i = 0; _i < _n; _i++) {
            if (_rooms[_i] != _goal && _rooms[_i].type == PG_ROOM.OFFICE) { _rooms[_i].type = PG_ROOM.STORAGE; break; }
        }
    }
}

function procgen_wet(_r, _kit, _bath) {
    return (!is_undefined(_kit)  && procgen_in(_r.links, _kit.idx))
        || (!is_undefined(_bath) && procgen_in(_r.links, _bath.idx));
}


// ============================================================================
//  VALIDAÇÃO
// ============================================================================
function procgen_validate(_plan) {
    var _cols = _plan.cols, _rows = _plan.rows, _grid = _plan.grid;

    var _total = 0;
    for (var _x = 0; _x < _cols; _x++)
        for (var _y = 0; _y < _rows; _y++)
            if (ds_grid_get(_grid, _x, _y) != PG_TILE.WALL) _total++;

    var _seen = array_create(_cols * _rows, false);
    var _s = _plan.start.cx + _plan.start.cy * _cols;
    var _stack = [_s];
    _seen[_s] = true;
    var _count = 0;

    while (array_length(_stack) > 0) {
        var _p = array_pop(_stack);
        _count++;
        var _px = _p mod _cols, _py = _p div _cols;
        for (var _d = 0; _d < 4; _d++) {
            var _nx = _px + ((_d == 0) - (_d == 1));
            var _ny = _py + ((_d == 2) - (_d == 3));
            if (_nx < 0 || _ny < 0 || _nx >= _cols || _ny >= _rows) continue;
            var _q = _nx + _ny * _cols;
            if (_seen[_q] || ds_grid_get(_grid, _nx, _ny) == PG_TILE.WALL) continue;
            _seen[_q] = true;
            array_push(_stack, _q);
        }
    }
    return _count == _total;
}


function procgen_walk(_plan) {
    var _cols = _plan.cols, _rows = _plan.rows;
    var _free = array_create(_cols * _rows, false);
    for (var _x = 0; _x < _cols; _x++)
        for (var _y = 0; _y < _rows; _y++)
            _free[_x + _y * _cols] = (ds_grid_get(_plan.grid, _x, _y) != PG_TILE.WALL) && (ds_grid_get(_plan.decor, _x, _y) == 0);

    var _ok = array_create(_cols * _rows, false);
    for (var _x = 0; _x < _cols - 1; _x++) {
        for (var _y = 0; _y < _rows - 1; _y++) {
            var _i = _x + _y * _cols;
            _ok[_i] = _free[_i] && _free[_i + 1] && _free[_i + _cols] && _free[_i + _cols + 1];
        }
    }

    var _walk = array_create(_cols * _rows, false);
    var _seen = array_create(_cols * _rows, false);
    var _stack = [];
    for (var _a = 0; _a <= 1; _a++) {
        for (var _b = 0; _b <= 1; _b++) {
            var _sx = _plan.start.cx - _a, _sy = _plan.start.cy - _b;
            if (_sx < 0 || _sy < 0) continue;
            var _s = _sx + _sy * _cols;
            if (_ok[_s] && !_seen[_s]) { _seen[_s] = true; array_push(_stack, _s); }
        }
    }

    while (array_length(_stack) > 0) {
        var _p = array_pop(_stack);
        var _px = _p mod _cols, _py = _p div _cols;
        _walk[_p] = true; _walk[_p + 1] = true; _walk[_p + _cols] = true; _walk[_p + _cols + 1] = true;
        for (var _d = 0; _d < 4; _d++) {
            var _nx = _px + ((_d == 0) - (_d == 1));
            var _ny = _py + ((_d == 2) - (_d == 3));
            if (_nx < 0 || _ny < 0 || _nx >= _cols - 1 || _ny >= _rows - 1) continue;
            var _q = _nx + _ny * _cols;
            if (_seen[_q] || !_ok[_q]) continue;
            _seen[_q] = true;
            array_push(_stack, _q);
        }
    }
    return _walk;
}

// depois da decoração, toda sala e a saída precisam continuar alcançáveis
function procgen_validate_decor(_plan) {
    var _walk = procgen_walk(_plan);
    var _cols = _plan.cols;

    for (var _i = 0; _i < array_length(_plan.rooms); _i++) {
        var _r = _plan.rooms[_i];
        var _any = false;
        for (var _x = _r.x + 1; _x <= _r.x + _r.w - 2 && !_any; _x++)
            for (var _y = _r.y + 1; _y <= _r.y + _r.h - 2 && !_any; _y++)
                if (_walk[_x + _y * _cols]) _any = true;
        if (!_any) return false;
    }
    if (!_walk[_plan.goal.cx + _plan.goal.cy * _cols]) return false;

    _plan.walk = _walk;
    return true;
}


// ============================================================================
// DECORAÇÃO
// ============================================================================

function procgen_decorate(_plan, _cfg) {
    _plan.props = [];
    _plan.strips = [];
    _plan.stools = [];
    _plan.wall_used = {};
    var _defs = procgen_props();
    var _presets = procgen_presets();

    for (var _i = 0; _i < array_length(_plan.rooms); _i++) {
        var _r = _plan.rooms[_i];
        _r.focus_x = -1;
        _r.placed = {};
        procgen_rug(_plan, _cfg, _r);

        var _rules = _presets[_r.type];
        for (var _k = 0; _k < array_length(_rules); _k++) {
            var _rule = _rules[_k];

            if (_rule.at == PG_AT.RUN) {
                procgen_place_run(_plan, _defs, _r, _rule.runs[irandom(array_length(_rule.runs) - 1)]);
                continue;
            }
            repeat (irandom_range(_rule.lo, _rule.hi)) {
                if (_rule.at == PG_AT.WALL) procgen_place_wall(_plan, _defs, _r, _rule.prop);
                else procgen_place_one(_plan, _defs, _r, _rule);
            }
        }
    }
}

// tapete
function procgen_rug(_plan, _cfg, _r) {
    var _sets = _cfg.rugs[_r.type];
    if (array_length(_sets) == 0) return;
    var _pick = _sets[irandom(array_length(_sets) - 1)];
    var _iw = _r.w - 2, _ih = _r.h - 2 - PG_FACE;
    var _fy = _r.y + 1 + PG_FACE;     

    if (is_struct(_pick)) { // sprite
        var _w = sprite_get_width(_pick.spr), _h = sprite_get_height(_pick.spr);
        if (_w > _iw * _plan.cell - 32 || _h > _ih * _plan.cell - 32) return;
        array_push(_plan.props, { spr: _pick.spr, kind: "rug", chair: false, el: -1,
            x: (_r.x + 1) * _plan.cell + (_iw * _plan.cell - _w) div 2,
            y: _fy * _plan.cell + (_ih * _plan.cell - _h) div 2 });
        return;
    }

    var _rw = max(3, floor(_iw * _cfg.rug_scale[_r.type]));
    var _rh = max(3, floor(_ih * _cfg.rug_scale[_r.type]));
    if (_rw > _iw - 2 || _rh > _ih - 2) return; // sem margem de chão

    var _x0 = _r.x + 1 + (_iw - _rw) div 2;
    var _y0 = _fy + (_ih - _rh) div 2;
    for (var _i = 0; _i < _rw; _i++) {
        for (var _j = 0; _j < _rh; _j++) {
            var _col = (_i == 0) ? 0 : ((_i == _rw - 1) ? 2 : 1);
            var _row = (_j == 0) ? 0 : ((_j == _rh - 1) ? 2 : 1);
            ds_grid_set(_plan.rug, _x0 + _i, _y0 + _j, _pick[_row * 3 + _col]);
        }
    }
}

// sprite do móvel
function procgen_pick_spr(_def, _side) {
    if (_side == "l" && variable_struct_exists(_def, "spr_l")) return _def.spr_l;
    if (_side == "r" && variable_struct_exists(_def, "spr_r")) return _def.spr_r;
    return is_array(_def.spr) ? _def.spr[irandom(array_length(_def.spr) - 1)] : _def.spr;
}

// footprint em células
function procgen_footprint(_spr, _def, _top) {
    var _w = sprite_get_width(_spr), _h = sprite_get_height(_spr);
    var _fw = variable_struct_exists(_def, "fw") ? _def.fw : max(1, (_w + 8) div 16);
    var _fh;
    if (variable_struct_exists(_def, "fh")) _fh = _def.fh;
    else _fh = _top ? max(1, ceil((_h - 16 * PG_FACE) / 16)) : max(1, (_h + 8) div 16);
    return [_fw, _fh];
}

function procgen_area_ok(_plan, _x, _y, _w, _h, _ring) {
    for (var _dx = 0; _dx < _w; _dx++)
        for (var _dy = 0; _dy < _h; _dy++)
            if (!procgen_cell_free(_plan, _x + _dx, _y + _dy)) return false;
    if (!_ring) return true;

    for (var _dx = -1; _dx <= _w; _dx++) {
        for (var _dy = -1; _dy <= _h; _dy++) {
            var _nx = _x + _dx, _ny = _y + _dy;
            if (_nx < 0 || _ny < 0 || _nx >= _plan.cols || _ny >= _plan.rows) continue;
            if (ds_grid_get(_plan.decor, _nx, _ny) != 0) return false;
        }
    }
    return true;
}

// registra o móvel
function procgen_put(_plan, _def, _spr, _x, _y, _fw, _fh) {
    var _c = _plan.cell;
    var _w = sprite_get_width(_spr), _h = sprite_get_height(_spr);
    var _p = {
        spr: _spr, kind: "prop", el: -1,
        x: _x * _c + (_fw * _c - _w) div 2,
        y: (_y + _fh) * _c - _h,
        cx: _x, cy: _y + _fh - 1,
        chair: variable_struct_exists(_def, "chair") && _def.chair
    };
    array_push(_plan.props, _p);
    var _id = array_length(_plan.props);
    for (var _dx = 0; _dx < _fw; _dx++)
        for (var _dy = 0; _dy < _fh; _dy++)
            ds_grid_set(_plan.decor, _x + _dx, _y + _dy, _id);
    if (_p.chair) array_push(_plan.stools, [_p.cx, _p.cy]);

    var _over = _h - _fh * _c;
    if (_over > 0 && _y - 1 >= 0) {
        for (var _dx = 0; _dx < _fw; _dx++) {
            if (ds_grid_get(_plan.grid, _x + _dx, _y - 1) != PG_TILE.FLOOR) continue; // parede/painel já bloqueia
            if (ds_grid_get(_plan.decor, _x + _dx, _y - 1) != 0) continue;
            array_push(_plan.strips, [_x + _dx, _y - 1, _over]);
        }
    }

    // objetos pequenos em cima
    if (variable_struct_exists(_def, "tops")) {
        var _slots = max(1, _w div 22);
        var _sw = _w div _slots;
        for (var _s = 0; _s < _slots; _s++) {
            if (random(1) > 0.65) continue;
            var _t = _def.tops[irandom(array_length(_def.tops) - 1)];
            var _tw = sprite_get_width(_t), _th = sprite_get_height(_t);
            array_push(_plan.props, { spr: _t, kind: "top", chair: false, el: -1,
                x: _p.x + _s * _sw + irandom(max(0, _sw - _tw)),
                y: _p.y + _def.top_y - _th });
        }
    }

    // cadeira embaixo
    if (variable_struct_exists(_def, "seat")) {
        var _sx = _x + _fw div 2, _sy = _y + _fh;
        if (procgen_cell_free(_plan, _sx, _sy)) procgen_put(_plan, _def.seat, procgen_pick_spr(_def.seat, ""), _sx, _sy, 1, 1);
    }
}

// cadeiras dos dois lados da mesa
function procgen_flank(_plan, _def, _x, _y, _fw, _fh) {
    var _sy = _y + _fh - 1;
    for (var _s = 0; _s < 2; _s++) {
        var _sx = (_s == 0) ? _x - 1 : _x + _fw;
        if (!procgen_cell_free(_plan, _sx, _sy)) continue;
        procgen_put(_plan, _def, procgen_pick_spr(_def, (_s == 0) ? "l" : "r"), _sx, _sy, 1, 1);
    }
}

// fileira colada na parede de cima
function procgen_place_run(_plan, _defs, _r, _names) {
    var _all = procgen_required();
    var _req = _all[_r.type]; // essenciais do cômodo
    var _items = [];
    for (var _i = 0; _i < array_length(_names); _i++) {
        var _def = variable_struct_get(_defs, _names[_i]);
        var _spr = procgen_pick_spr(_def, "");
        var _fp = procgen_footprint(_spr, _def, true);
        array_push(_items, { name: _names[_i], def: _def, spr: _spr, fw: _fp[0], fh: _fp[1] });
    }
    var _x0 = _r.x + 1, _y0 = _r.y + 1 + PG_FACE, _iw = _r.w - 2;

    while (array_length(_items) > 0) {
        var _sum = 0, _fhm = 1;
        for (var _i = 0; _i < array_length(_items); _i++) {
            _sum += _items[_i].fw;
            _fhm = max(_fhm, _items[_i].fh);
        }
        if (_sum <= _iw) {
            for (var _t = 0; _t < 12; _t++) {
                var _sx = irandom_range(_x0, _x0 + _iw - _sum);
                if (!procgen_area_ok(_plan, _sx, _y0, _sum, _fhm, true)) continue;
                for (var _i = 0; _i < array_length(_items); _i++) {
                    var _it = _items[_i];
                    procgen_put(_plan, _it.def, _it.spr, _sx, _y0, _it.fw, _it.fh);
                    procgen_mark(_r, _it.name);
                    if (_it.name == "tv" || _it.name == "fireplace") _r.focus_x = _sx + _it.fw div 2;
                    _sx += _it.fw;
                }
                return true;
            }
        }
        // não coube
        var _drop = array_length(_items) - 1;
        for (var _i = array_length(_items) - 1; _i >= 0; _i--) {
            var _n = _items[_i].name;
            if (!procgen_in(_req, _n) && _n != "tv" && _n != "fireplace") { _drop = _i; break; }
        }
        array_delete(_items, _drop, 1);
    }
    return false;
}

// um móvel numa posição sorteada
function procgen_place_one(_plan, _defs, _r, _rule) {
    var _def = variable_struct_get(_defs, _rule.prop);
    var _spr = procgen_pick_spr(_def, "");
    var _ft = procgen_footprint(_spr, _def, true);  // colado na parede de cima
    var _ff = procgen_footprint(_spr, _def, false);
    var _x0 = _r.x + 1, _y0 = _r.y + 1 + PG_FACE, _x1 = _r.x + _r.w - 2, _y1 = _r.y + _r.h - 2;

    var _c = [];
    switch (_rule.at) {
        case PG_AT.TOP:
            for (var _x = _x0; _x <= _x1 - _ft[0] + 1; _x++) array_push(_c, [_x, _y0, "", true]);
        break;
        case PG_AT.BOTTOM:
            for (var _x = _x0; _x <= _x1 - _ff[0] + 1; _x++) array_push(_c, [_x, _y1 - _ff[1] + 1, "", false]);
        break;
        case PG_AT.SIDE:
            for (var _y = _y0; _y <= _y1 - _ff[1] + 1; _y++) array_push(_c, [_x0, _y, "l", false], [_x1 - _ff[0] + 1, _y, "r", false]);
        break;
        case PG_AT.CORNER:
            array_push(_c, [_x0, _y0, "l", true], [_x1 - _ft[0] + 1, _y0, "r", true],
                           [_x0, _y1 - _ff[1] + 1, "l", false], [_x1 - _ff[0] + 1, _y1 - _ff[1] + 1, "r", false]);
        break;
        case PG_AT.CENTER: // o mais perto do centro da sala
            var _ccx = (_rule.prop == "sofa" && _r.focus_x >= 0) ? _r.focus_x : _r.cx;
            var _jit = (_r.focus_x >= 0) ? 0.4 : 1.5;
			var _align = (_rule.prop == "sofa" && _r.focus_x >= 0);
			var _wx = _align ? 4 : 1;
            for (var _dx = -3; _dx <= 3; _dx++)
                for (var _dy = -3; _dy <= 3; _dy++)
                    array_push(_c, [_ccx - _ff[0] div 2 + _dx, _r.cy - _ff[1] div 2 + _dy, "", false, abs(_dx) * _wx + abs(_dy) + ((_align && _dy < 0) ? 0.5 : 0) + random(_jit)]);
        break;
        default:
            for (var _x = _x0; _x <= _x1; _x++)
                for (var _y = _y0; _y <= _y1; _y++) array_push(_c, [_x, _y, "", false]);
        break;
    }
    if (_rule.at == PG_AT.CENTER) array_sort(_c, function(_a, _b) { return sign(_a[4] - _b[4]); });
    else procgen_shuffle(_c);

    for (var _i = 0; _i < array_length(_c); _i++) {
        var _p = _c[_i];
        var _fp = _p[3] ? _ft : _ff;
        if (_p[0] < _x0 || _p[1] < _y0 || _p[0] + _fp[0] - 1 > _x1 || _p[1] + _fp[1] - 1 > _y1) continue;
        if (!procgen_area_ok(_plan, _p[0], _p[1], _fp[0], _fp[1], true)) continue;

        procgen_put(_plan, _def, procgen_pick_spr(_def, _p[2]), _p[0], _p[1], _fp[0], _fp[1]);
        procgen_mark(_r, _rule.prop);
        if (variable_struct_exists(_rule, "flank")) {
            procgen_flank(_plan, variable_struct_get(_defs, _rule.flank), _p[0], _p[1], _fp[0], _fp[1]);
        }
        return true;
    }
    return false;
}

function procgen_place_wall(_plan, _defs, _r, _prop) {
    var _def = variable_struct_get(_defs, _prop);
    var _spr = procgen_pick_spr(_def, "");
    var _w = sprite_get_width(_spr), _h = sprite_get_height(_spr);
    var _fw = max(1, (_w + 8) div 16);
    var _fy = _r.y + 1; // primeira linha do painel
    var _fb = _r.y + 1 + PG_FACE;   // primeira linha de chão

    var _xs = [];
    for (var _x = _r.x + 1; _x <= _r.x + _r.w - 2 - _fw + 1; _x++) array_push(_xs, _x);
    procgen_shuffle(_xs);

    for (var _i = 0; _i < array_length(_xs); _i++) {
        var _x = _xs[_i], _ok = true;
        for (var _k = -1; _k <= _fw && _ok; _k++) {
            var _cx = _x + _k;
            _ok = ds_grid_get(_plan.decor, _cx, _fb) == 0
               && !variable_struct_exists(_plan.wall_used, string(_cx) + "_" + string(_fy));
            if (_ok && _k >= 0 && _k < _fw) _ok = ds_grid_get(_plan.face, _cx, _fy) == 1;
        }
        if (!_ok) continue;

        for (var _k = -1; _k <= _fw; _k++) variable_struct_set(_plan.wall_used, string(_x + _k) + "_" + string(_fy), true);
        array_push(_plan.props, { spr: _spr, kind: "prop", chair: false, el: -1,
            x: _x * _plan.cell + (_fw * _plan.cell - _w) div 2,
            y: _fy * _plan.cell + (PG_FACE * _plan.cell - _h) div 2 - 2 });
        return true;
    }
    return false;
}

function procgen_required() {
    var _q = array_create(6, []);
    _q[PG_ROOM.LIVING]   = ["sofa"];
    _q[PG_ROOM.KITCHEN]  = ["fridge", "stove", "sink", "table"];
    _q[PG_ROOM.BATHROOM] = ["toilet", "sink"];
    _q[PG_ROOM.STORAGE]  = [];
    _q[PG_ROOM.OFFICE]   = ["desk"];
    _q[PG_ROOM.LAUNDRY]  = ["sink"];
    return _q;
}

function procgen_mark(_r, _name) {
    variable_struct_set(_r.placed, _name, true);
}

function procgen_has_required(_plan) {
    var _req = procgen_required();
    for (var _i = 0; _i < array_length(_plan.rooms); _i++) {
        var _r = _plan.rooms[_i];
        var _list = _req[_r.type];
        for (var _k = 0; _k < array_length(_list); _k++) {
            if (!variable_struct_exists(_r.placed, _list[_k])) return false;
        }
        if (_r.type == PG_ROOM.LIVING && !variable_struct_exists(_r.placed, "tv") && !variable_struct_exists(_r.placed, "fireplace")) return false;
    }
    return true;
}

// chão livre, sem porta por perto, fora da entrada e da saída
function procgen_cell_free(_plan, _x, _y) {
    if (ds_grid_get(_plan.grid, _x, _y) != PG_TILE.FLOOR) return false;
    if (ds_grid_get(_plan.decor, _x, _y) != 0) return false;

    for (var _dx = -2; _dx <= 2; _dx++) {
        for (var _dy = -2; _dy <= 2; _dy++) {
            var _nx = _x + _dx, _ny = _y + _dy;
            if (_nx < 0 || _ny < 0 || _nx >= _plan.cols || _ny >= _plan.rows) continue;
            if (ds_grid_get(_plan.grid, _nx, _ny) == PG_TILE.DOOR) return false;
        }
    }
    if (abs(_x - _plan.start.cx) <= 1 && abs(_y - _plan.start.cy) <= 1) return false;
    if (abs(_x - _plan.goal.cx)  <= 1 && abs(_y - _plan.goal.cy)  <= 1) return false;
    return true;
}


// ============================================================================
//  APLICAÇÃO
// ============================================================================

function procgen_apply(_plan, _cfg, _ox, _oy) {
    // limpa os tiles pintados no editor antes de aplicar
    var _clear = [_cfg.layer_floor, _cfg.layer_wall, _cfg.layer_collision, _cfg.layer_decor, "BottomWalls"];
    for (var _c = 0; _c < array_length(_clear); _c++) {
        var _cm = procgen_layer_map(_clear[_c]);
        if (_cm != -1) tilemap_clear(_cm, 0);
    }

    var _mf = procgen_layer_map(_cfg.layer_floor);
    var _mw = procgen_layer_map(_cfg.layer_wall);
    if (_mf != -1) tilemap_tileset(_mf, _cfg.tileset_floor);
    if (_mw != -1) tilemap_tileset(_mw, _cfg.tileset_walls);

    // tipo do cômodo de cada célula
    var _rtype = array_create(_plan.cols * _plan.rows, -1);
    for (var _i = 0; _i < array_length(_plan.rooms); _i++) {
        var _r = _plan.rooms[_i];
        for (var _rx = _r.x + 1; _rx <= _r.x + _r.w - 2; _rx++)
            for (var _ry = _r.y + 1; _ry <= _r.y + _r.h - 2; _ry++) _rtype[_rx + _ry * _plan.cols] = _r.type;
    }
    var _mc = procgen_layer_map(_cfg.layer_collision);
    var _mr = procgen_apply_props(_plan, _cfg, _ox, _oy); // tapetes e sprites

    for (var _i = 0; _i < array_length(_plan.frames); _i++) {
        var _f = _plan.frames[_i];
        var _ft = _f[2] ? _cfg.door_top[_f[3]] : _cfg.door_bot[_f[3]];
        if (_plan.map_frames != -1) tilemap_set(_plan.map_frames, _ft, _ox + _f[0], _oy + _f[1]);
    }

    for (var _i = 0; _i < array_length(_plan.lid_cells); _i++) {
        var _l = _plan.lid_cells[_i];
        if (_plan.map_frames != -1) tilemap_set(_plan.map_frames, procgen_wall_tile(_plan, _cfg, _l[0], _l[1]), _ox + _l[0], _oy + _l[1]);
    }

    for (var _x = 0; _x < _plan.cols; _x++) {
        for (var _y = 0; _y < _plan.rows; _y++) {
            var _t = ds_grid_get(_plan.grid, _x, _y);
            var _tx = _ox + _x, _ty = _oy + _y;

            if (_t == PG_TILE.WALL) {
                if (_mw != -1) {
                    var _tile;
                    if (ds_grid_get(_plan.face, _x, _y) == 1) { // painel: linha de cima ou de baixo
                        var _low = (_y > 0 && ds_grid_get(_plan.face, _x, _y - 1) == 1);
                        _tile = _low ? _cfg.face_bot[_x mod 2] : _cfg.face_top[_x mod 2];
                    } else {
                        _tile = procgen_wall_tile(_plan, _cfg, _x, _y);
                    }
                    tilemap_set(_mw, _tile, _tx, _ty);
                }
                procgen_set_collision(_mc, _cfg, _tx, _ty);
            } else {
                if (_mf != -1) {
                    var _rt = _rtype[_x + _y * _plan.cols];
                    var _pair = _cfg.floors[max(0, _rt)];
                    tilemap_set(_mf, _pair[(_x + _y) mod 2], _tx, _ty); // xadrez
                }

                var _rug = ds_grid_get(_plan.rug, _x, _y);
                if (_rug > 0 && _mr != -1) tilemap_set(_mr, _rug, _tx, _ty);

                if (_cfg.decor_blocks && ds_grid_get(_plan.decor, _x, _y) > 0) procgen_set_collision(_mc, _cfg, _tx, _ty);
            }
        }
    }

    if (_cfg.decor_blocks) {
        for (var _i = 0; _i < array_length(_plan.strips); _i++) {
            var _st = _plan.strips[_i];
            procgen_set_collision_strip(_mc, _cfg, _ox + _st[0], _oy + _st[1], _st[2]);
        }
    }
}

function procgen_apply_props(_plan, _cfg, _ox, _oy) {
    var _names = ["PG_Rugs", "PG_Props", "PG_Tops", "PG_Frames"];
    var _depth = [_cfg.depth_rugs, _cfg.depth_props, _cfg.depth_tops, _cfg.depth_frames];
    var _ly = [];
    for (var _i = 0; _i < 4; _i++) {
        if (layer_exists(_names[_i])) layer_destroy(_names[_i]);
        array_push(_ly, layer_create(_depth[_i], _names[_i]));
    }
    var _map = layer_tilemap_create(_ly[0], 0, 0, _cfg.tileset_rugs, room_width div _cfg.cell, room_height div _cfg.cell);
    _plan.map_frames = layer_tilemap_create(_ly[3], 0, 0, _cfg.tileset_rugs, room_width div _cfg.cell, room_height div _cfg.cell);

    for (var _i = 0; _i < array_length(_plan.props); _i++) {
        var _p = _plan.props[_i];
        var _l = (_p.kind == "rug") ? _ly[0] : ((_p.kind == "top") ? _ly[2] : _ly[1]);
        _p.el = layer_sprite_create(_l, _ox * _cfg.cell + _p.x, _oy * _cfg.cell + _p.y, _p.spr);
        layer_sprite_speed(_p.el, 0);
    }
    return _map;
}

function procgen_verify_applied(_plan, _cfg, _ox, _oy) {
    _plan.mismatch = [];
    var _mc = procgen_layer_map(_cfg.layer_collision);
    if (_mc == -1) return 0;

    var _k = max(1, _cfg.cell div tilemap_get_tile_width(_mc));
    var _skip = {}; // células com só uma faixa de colisão
    for (var _i = 0; _i < array_length(_plan.strips); _i++) variable_struct_set(_skip, string(_plan.strips[_i][0]) + "_" + string(_plan.strips[_i][1]), true);
    for (var _x = 0; _x < _plan.cols; _x++) {
        for (var _y = 0; _y < _plan.rows; _y++) {
            if (variable_struct_exists(_skip, string(_x) + "_" + string(_y))) continue;
            var _want = (ds_grid_get(_plan.grid, _x, _y) == PG_TILE.WALL)
                     || (_cfg.decor_blocks && ds_grid_get(_plan.decor, _x, _y) > 0);
            var _n = 0;
            for (var _i = 0; _i < _k; _i++)
                for (var _j = 0; _j < _k; _j++)
                    if (tile_get_index(tilemap_get(_mc, (_ox + _x) * _k + _i, (_oy + _y) * _k + _j)) != 0) _n++;
            if ((_want && _n < _k * _k) || (!_want && _n > 0)) array_push(_plan.mismatch, [_x, _y]);
        }
    }
    if (array_length(_plan.mismatch) > 0) show_debug_message("procgen: " + string(array_length(_plan.mismatch)) + " celulas com plano != colisao da fase");
    return array_length(_plan.mismatch);
}

function procgen_is_wall(_plan, _x, _y) {
    if (_x < 0 || _y < 0 || _x >= _plan.cols || _y >= _plan.rows) return 0;
    if (ds_grid_get(_plan.face, _x, _y) == 1) return 0;
    if (ds_grid_get(_plan.grid, _x, _y) == PG_TILE.WALL) return 1;
    return variable_struct_exists(_plan.lids, string(_x) + "_" + string(_y)) ? 1 : 0;
}

// parede estrutural pelos 4 vizinhos
function procgen_wall_tile(_plan, _cfg, _x, _y) {
    var _n = procgen_is_wall(_plan, _x, _y - 1);
    var _e = procgen_is_wall(_plan, _x + 1, _y);
    var _s = procgen_is_wall(_plan, _x, _y + 1);
    var _w = procgen_is_wall(_plan, _x - 1, _y);

    if ((_e || _w) && !_n && !_s) return _cfg.wall_h[_w ? (_e ? 1 : 2) : 0];
    if ((_n || _s) && !_e && !_w) return _cfg.wall_v[_n ? (_s ? 1 : 2) : 0];

    if (_e && _s && !_n && !_w) return _cfg.wall_corner.tl;
    if (_s && _w && !_n && !_e) return _cfg.wall_corner.tr;
    if (_n && _e && !_s && !_w) return _cfg.wall_corner.bl;
    if (_n && _w && !_s && !_e) return _cfg.wall_corner.br;
    return _cfg.wall_block;
}

function procgen_layer_map(_name) {
    if (_name == "" || !layer_exists(_name)) return -1;
    return layer_tilemap_get_id(_name);
}

// collision_tile_set é 8x8 e o grid 16x16, células tem 2x2 de colisão
function procgen_set_collision(_map, _cfg, _tx, _ty) {
    if (_map == -1) return;
    var _k = max(1, _cfg.cell div tilemap_get_tile_width(_map));
    for (var _i = 0; _i < _k; _i++)
        for (var _j = 0; _j < _k; _j++)
            tilemap_set(_map, _cfg.tile_collision, _tx * _k + _i, _ty * _k + _j);
}

// colisão só na parte de baixo da célula
function procgen_set_collision_strip(_map, _cfg, _tx, _ty, _px) {
    if (_map == -1) return;
    var _tw = tilemap_get_tile_width(_map);
    var _k = max(1, _cfg.cell div _tw);
    var _rows = clamp(ceil(_px / _tw), 1, _k);
    for (var _i = 0; _i < _k; _i++)
        for (var _j = _k - _rows; _j < _k; _j++)
            tilemap_set(_map, _cfg.tile_collision, _tx * _k + _i, _ty * _k + _j);
}

// paredes e móveis no mp_grid do obj_manager
function procgen_sync_mp_grid(_plan, _cfg, _ox, _oy, _mp) {
    for (var _x = 0; _x < _plan.cols; _x++) {
        for (var _y = 0; _y < _plan.rows; _y++) {
            var _blocked = ds_grid_get(_plan.grid, _x, _y) == PG_TILE.WALL
                        || (_cfg.decor_blocks && ds_grid_get(_plan.decor, _x, _y) > 0);
            if (_blocked) mp_grid_add_cell(_mp, _ox + _x, _oy + _y);
        }
    }
    if (_cfg.decor_blocks) {
        for (var _i = 0; _i < array_length(_plan.strips); _i++) mp_grid_add_cell(_mp, _ox + _plan.strips[_i][0], _oy + _plan.strips[_i][1]);
    }
}

// centro da célula em pixels
function procgen_cell_to_px(_cell_x, _cell_y, _cfg, _ox, _oy) {
    return [(_ox + _cell_x) * _cfg.cell + _cfg.cell div 2,
            (_oy + _cell_y) * _cfg.cell + _cfg.cell div 2];
}

// célula de chão livre e alcançável dentro da sala
function procgen_random_free_cell(_plan, _r, _open = false) {
    for (var _t = 0; _t < 40; _t++) {
        var _x = irandom_range(_r.x + 1, _r.x + _r.w - 2);
        var _y = irandom_range(_r.y + 1, _r.y + _r.h - 2);
        if (ds_grid_get(_plan.grid, _x, _y) != PG_TILE.FLOOR) continue;
        if (!_plan.walk[_x + _y * _plan.cols]) continue;
        if (_open && !procgen_cell_open(_plan, _x, _y)) continue;
        return [_x, _y];
    }
    return undefined;
}

function procgen_cell_open(_plan, _x, _y) {
    for (var _dx = -1; _dx <= 1; _dx++) {
        for (var _dy = -1; _dy <= 1; _dy++) {
            var _nx = _x + _dx, _ny = _y + _dy;
            if (_nx < 0 || _ny < 0 || _nx >= _plan.cols || _ny >= _plan.rows) return false;
            if (!_plan.walk[_nx + _ny * _plan.cols]) return false;
        }
    }
    return true;
}


// ============================================================================
//  INIMIGOS
// ============================================================================

function enemy_blocked_at(_x, _y) {
    if (place_meeting(_x, _y, obj_obstacle)) return true;
    for (var _i = 0; _i < array_length(global.solid_maps); _i++) {
        if (place_meeting(_x, _y, global.solid_maps[_i])) return true;
    }
    return false;
}

function enemy_unstick(_max_r = 48) {
    if (!enemy_blocked_at(x, y)) return true;
    for (var _r = 2; _r <= _max_r; _r += 2) {
        for (var _a = 0; _a < 360; _a += 30) {
            var _nx = x + lengthdir_x(_r, _a);
            var _ny = y + lengthdir_y(_r, _a);
            if (!enemy_blocked_at(_nx, _ny)) { x = _nx; y = _ny; return true; }
        }
    }
    return false;
}

// cria o inimigo numa célula aberta e confere a máscara real dele
function procgen_spawn_enemy(_obj, _plan, _cfg, _ox, _oy, _rooms) {
    for (var _t = 0; _t < 30; _t++) {
        var _room = _rooms[irandom(array_length(_rooms) - 1)];
        var _c = procgen_random_free_cell(_plan, _room, true);
        if (is_undefined(_c)) continue;

        var _p = procgen_cell_to_px(_c[0], _c[1], _cfg, _ox, _oy);
        var _e = instance_create_layer(_p[0], _p[1], "Instances", _obj);
        var _fits = false;
        with (_e) _fits = enemy_unstick();
        if (_fits) return _e;
        instance_destroy(_e);
    }
    return noone;
}

// transforma n cadeiras em mímicos
function procgen_spawn_mimics(_plan, _cfg, _ox, _oy, _n) {
    if (_n <= 0) return;

    var _cells = [];
    for (var _i = 0; _i < array_length(_plan.props); _i++) {
        var _p = _plan.props[_i];
        if (!_p.chair) continue;
        var _px = procgen_cell_to_px(_p.cx, _p.cy, _cfg, _ox, _oy);
        array_push(_cells, { px: _px[0], py: _px[1], el: _p.el });
    }
    _n = min(_n, array_length(_cells) - 1);
    if (_n <= 0) return; // precisa de cadeira sobrando pra ele trocar de lugar

    array_shuffle(_cells);
    var _shared = { cells: _cells, taken: array_create(array_length(_cells), false) };

    for (var _i = 0; _i < _n; _i++) {
        var _c = _cells[_i];
        _shared.taken[_i] = true;
        layer_sprite_alpha(_c.el, 0); // tira só o visual, a colisão continua
        instance_create_layer(_c.px, _c.py, "Instances", obj_mimic, { shared: _shared, cell_i: _i });
    }
}

// balões espalhados pelo andar
function procgen_spawn_balloons(_plan, _cfg, _ox, _oy, _n) {
    var _pool = [];
    for (var _i = 0; _i < array_length(_plan.rooms); _i++) {
        if (_plan.rooms[_i].dist >= 1) array_push(_pool, _plan.rooms[_i]);
    }
    if (array_length(_pool) == 0 || _n <= 0) return;

    var _made = 0;
    for (var _t = 0; _t < _n * 20 && _made < _n; _t++) {
        var _room = _pool[irandom(array_length(_pool) - 1)];
        var _c = procgen_random_free_cell(_plan, _room, true); // chão livre e alcançável
        if (is_undefined(_c)) continue;
        if (abs(_c[0] - _plan.goal.cx) <= 1 && abs(_c[1] - _plan.goal.cy) <= 1) continue; 

        var _p = procgen_cell_to_px(_c[0], _c[1], _cfg, _ox, _oy);
        var _near = instance_nearest(_p[0], _p[1], Balloon);
        if (_near != noone && point_distance(_p[0], _p[1], _near.x, _near.y) < 64) continue;

        instance_create_layer(_p[0], _p[1], "Instances", Balloon);
        _made++;
    }
}

// ============================================================================
//  DEBUG
// ============================================================================
function procgen_debug_draw(_plan, _px, _py, _s) {
    // sala, cozinha, banheiro, despensa, escritório, lavanderia
    var _room_col = [make_color_rgb(70,110,160), make_color_rgb(190,140,70), make_color_rgb(140,100,160),
                     make_color_rgb(150,120,100), make_color_rgb(90,170,170), make_color_rgb(110,150,90)];

    for (var _x = 0; _x < _plan.cols; _x++) {
        for (var _y = 0; _y < _plan.rows; _y++) {
            var _t = ds_grid_get(_plan.grid, _x, _y);
            var _col = c_black;
            if (_t == PG_TILE.DOOR)  _col = c_yellow;
            if (_t == PG_TILE.FLOOR) _col = c_dkgray;
            if (ds_grid_get(_plan.decor, _x, _y) > 0) _col = c_fuchsia;
            draw_set_color(_col);
            draw_rectangle(_px + _x*_s, _py + _y*_s, _px + _x*_s + _s - 1, _py + _y*_s + _s - 1, false);
        }
    }
    // cor do cômodo
    draw_set_alpha(0.45);
    for (var _i = 0; _i < array_length(_plan.rooms); _i++) {
        var _r = _plan.rooms[_i];
        draw_set_color(_room_col[_r.type]);
        draw_rectangle(_px + (_r.x+1)*_s, _py + (_r.y+1)*_s, _px + (_r.x+_r.w-1)*_s - 1, _py + (_r.y+_r.h-1)*_s - 1, false);
    }
    draw_set_alpha(1);

    // plano diverge da colisão
    if (variable_struct_exists(_plan, "mismatch")) {
        draw_set_color(c_red);
        for (var _m = 0; _m < array_length(_plan.mismatch); _m++) {
            var _c = _plan.mismatch[_m];
            draw_rectangle(_px + _c[0]*_s, _py + _c[1]*_s, _px + _c[0]*_s + _s - 1, _py + _c[1]*_s + _s - 1, true);
        }
    }
    // ciano: Player
    if (instance_exists(Player)) {
        var _pcx = floor(Player.x / _plan.cell) - _plan.ox;
        var _pcy = floor(Player.y / _plan.cell) - _plan.oy;
        draw_set_color(c_aqua);
        draw_circle(_px + _pcx*_s + _s/2, _py + _pcy*_s + _s/2, _s/2 + 1, false);
    }

    // laranja: lanterna, verde: copo de água
    var _items = [[obj_flashlight, c_orange], [obj_water_cup, c_lime]];
    for (var _k = 0; _k < array_length(_items); _k++) {
        draw_set_color(_items[_k][1]);
        with (_items[_k][0]) {
            var _icx = floor(x / _plan.cell) - _plan.ox;
            var _icy = floor(y / _plan.cell) - _plan.oy;
            draw_circle(_px + _icx*_s + _s/2, _py + _icy*_s + _s/2, max(2, _s * 0.6), false);
        }
    }

    // branco: cadeira
    draw_set_color(c_white);
    for (var _i = 0; _i < array_length(_plan.stools); _i++) {
        var _c = _plan.stools[_i];
        draw_rectangle(_px + _c[0]*_s + 1, _py + _c[1]*_s + 1, _px + _c[0]*_s + _s - 2, _py + _c[1]*_s + _s - 2, false);
    }

    // vermelho: mímico
    draw_set_color(c_red);
    with (obj_mimic) {
        var _mcx = floor(x / _plan.cell) - _plan.ox;
        var _mcy = floor(y / _plan.cell) - _plan.oy;
        draw_circle(_px + _mcx*_s + _s/2, _py + _mcy*_s + _s/2, max(2, _s * 0.6), false);
    }

    // E = entrada, S = saída
    draw_set_color(c_white);
    draw_text_transformed(_px + _plan.start.cx*_s, _py + _plan.start.cy*_s, "E", 0.5, 0.5, 0);
    draw_text_transformed(_px + _plan.goal.cx*_s,  _py + _plan.goal.cy*_s,  "S", 0.5, 0.5, 0);
    draw_text_transformed(_px, _py + _plan.rows*_s + 2, "seed " + string(_plan.seed) + "  salas " + string(array_length(_plan.rooms)) + "  portas " + string(array_length(_plan.doors)), 0.5, 0.5, 0);
    draw_text_transformed(_px, _py + _plan.rows*_s + 10, "F2 oculta  F3 novo andar", 0.5, 0.5, 0);
}


// ============================================================================
//  UTILITÁRIOS
// ============================================================================
function procgen_shuffle(_arr) {
    for (var _i = array_length(_arr) - 1; _i > 0; _i--) {
        var _j = irandom(_i);
        var _tmp = _arr[_i]; _arr[_i] = _arr[_j]; _arr[_j] = _tmp;
    }
}

function procgen_in(_arr, _v) {
    for (var _i = 0; _i < array_length(_arr); _i++) if (_arr[_i] == _v) return true;
    return false;
}


// primeiro tilemap existente entre os nomes
function layer_tilemap_first(_names) {
    for (var _i = 0; _i < array_length(_names); _i++) {
        if (layer_exists(_names[_i])) {
            var _m = layer_tilemap_get_id(_names[_i]);
            if (_m != -1) return _m;
        }
    }
    return noone;
}


// células para n itens, em salas diferentes, longe da entrada e da saída
function procgen_item_cells(_plan, _n) {
    var _pool = [];
    for (var _i = 0; _i < array_length(_plan.rooms); _i++) {
        if (_plan.rooms[_i].dist >= 1) array_push(_pool, _plan.rooms[_i]);
    }
    if (array_length(_pool) == 0) { 
        for (var _i = 0; _i < array_length(_plan.rooms); _i++) array_push(_pool, _plan.rooms[_i]);
    }
    procgen_shuffle(_pool);

    var _out = [];
    for (var _k = 0; _k < _n; _k++) {
        var _r = _pool[_k mod array_length(_pool)];
        for (var _t = 0; _t < 6; _t++) {
            var _c = procgen_random_free_cell(_plan, _r);
            if (is_undefined(_c)) continue;
            if (abs(_c[0] - _plan.goal.cx)  <= 1 && abs(_c[1] - _plan.goal.cy)  <= 1) continue;
            if (abs(_c[0] - _plan.start.cx) <= 1 && abs(_c[1] - _plan.start.cy) <= 1) continue;
            array_push(_out, _c);
            break;
        }
    }
    return _out;
}