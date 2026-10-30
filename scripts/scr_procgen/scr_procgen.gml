// 1 - Grid do andar (ds_grid, em tiles de 16px)
// 2 - BSP iterativo até atingir o tamanho mínimo de sala OU o nº de salas sorteado
// 3 - Eleger as salas (regras de cômodo) + entrada e saída
// 4 - Portas (conexão entre salas)
// 5 - Preset de decoração por cômodo
// 6 - Aplicação nos tilemaps / mp_grid / instâncias


enum PG_TILE  { WALL, FLOOR, DOOR } // valores do ds_grid
enum PG_ROOM  { LIVING, BEDROOM, KITCHEN, BATHROOM, DINING, OFFICE, STORAGE } // cômodos
enum PG_PLACE { WALL_TOP, WALL_ROW, CORNER, CENTER, ANY, WALL_SIDE } // onde um preset coloca o objeto


// ----------------------------------------------------------------------------
//  CONFIGURAÇÃO
// ----------------------------------------------------------------------------
function procgen_config() {
    var _f = procgen_floor();
    var _rooms = procgen_floor_rooms(_f);
    var _last = (_f >= 3);
    return {
        floor_n: _f,
        // tamanho do andar (em tiles)
        cols: 48,
        rows: 32,
        cell: 16,

        // BSP
        min_room: 8, // lado mínimo da sala
        min_rooms: _rooms, // número fixo de salas deste andar
        max_rooms: _rooms,
        floor_first_rooms: 5, // primeiro andar tem 5 salas
        floor_rooms_step: 2,  // +2 salas por andar
        floor_last: 3, // último andar, leva até a r_starting_room
        split_jitter: 0.2, // sempre divide no meio e varia até 20% do lado
        loop_chance: 0.25, // chance de abrir portas extras
        door_width: 2, // largura da porta

        // geração
        seed: -1, // aleatória
        max_attempts: 20,

        // tiles
        tile_floor: 153,
        tile_wall: 0,
        tile_collision: 1,

        // Paredes
        walls: [161, 163, 148, 160, 147, 155, 144, 164, 150, 162, 161, 173, 146, 166, 157, 165],
        wall_left: 152,
        wall_right: 154,
        wall_top: 145,

        // Tapetes 3x3 por cômodo
        rug_scale: 0.7, // tamanho do tapete
        rugs: [
            [[96, 97, 98, 104, 105, 106, 112, 113, 114], [99, 100, 101, 107, 108, 109, 115, 116, 117]],
            [[48, 49, 50, 56, 57, 58, 64, 65, 66],       [51, 52, 53, 59, 60, 61, 67, 68, 69]],
            [[3, 4, 5, 11, 12, 13, 19, 20, 21]],
            [],
            [[96, 97, 98, 104, 105, 106, 112, 113, 114]], // sala de jantar
            [[48, 49, 50, 56, 57, 58, 64, 65, 66]],       // escritório
            []
        ],

        // layers
        layer_floor: "Floor",
        layer_wall: "Walls",
        layer_collision: "Collision",
        layer_decor: "Decor",

        decor_blocks: true,

        // props dos presets
        props: {
            shelf: 187,
            cabinet: 188,
            dresser: 193,
            bed: [184, 185, 186],
            plant: [196, 197, 198],
            table: 190,
            stool: 204,
            chest: 199,
            barrel: 205,
            stove: 212,
            toilet: 194
        },

        // saída do andar
        exit_room: _last ? r_starting_room : r_procedural, // último andar
        next_floor: _last ? 1 : _f + 1,
        exit_x: _last ? 347 : -1,
        exit_y: _last ? 544 : -1,

        // inimigos
        chasers: 1,
        clowns: 1,
        rooms_per_chaser: 6, // +1 chaser a cada 6 salas
        rooms_per_clown: 8, // +1 palhaço a cada 8 salas 

        // itens espalhados
        items: [
            { obj: obj_flashlight, name: "flashlight", count: 1, unique: true  },
            { obj: obj_water_cup,  name: "water_cup",  count: 1, unique: false }
        ]
    };
}


// ----------------------------------------------------------------------------
//  PRESETS
// ----------------------------------------------------------------------------
function procgen_presets() {
    // móveis encostados
    // mesa fica no meio e banquinho ao redor de mesa
    var _p = array_create(7, []);
    _p[PG_ROOM.LIVING] = [ // sala: estantes na parede, mesa de centro, plantas nos cantos
        { prop: "shelf",   place: PG_PLACE.WALL_ROW,  lo: 4, hi: 6 },
        { prop: "cabinet", place: PG_PLACE.WALL_ROW,  lo: 1, hi: 2 },
        { prop: "table",   place: PG_PLACE.CENTER,    lo: 1, hi: 1, flank: "stool" },
        { prop: "plant",   place: PG_PLACE.CORNER,    lo: 2, hi: 3 },
        { prop: "shelf",   place: PG_PLACE.WALL_SIDE, lo: 1, hi: 2 },
        { prop: "cabinet", place: PG_PLACE.WALL_SIDE, lo: 1, hi: 1 },
        { prop: "chest",   place: PG_PLACE.CORNER,    lo: 0, hi: 1 }
    ];
    _p[PG_ROOM.BEDROOM] = [ // quarto: cama com a cabeceira na parede, cômoda, baú no canto
        { prop: "bed",     place: PG_PLACE.WALL_TOP,  lo: 1, hi: 1 },
        { prop: "dresser", place: PG_PLACE.WALL_ROW,  lo: 1, hi: 2 },
        { prop: "shelf",   place: PG_PLACE.WALL_ROW,  lo: 1, hi: 2 },
        { prop: "dresser", place: PG_PLACE.WALL_SIDE, lo: 1, hi: 1 },
        { prop: "cabinet", place: PG_PLACE.WALL_SIDE, lo: 1, hi: 1 },
        { prop: "chest",   place: PG_PLACE.CORNER,    lo: 1, hi: 1 },
        { prop: "plant",   place: PG_PLACE.CORNER,    lo: 1, hi: 2 }
    ];
    _p[PG_ROOM.KITCHEN] = [ // cozinha: bancada (fogão + armários) na parede, mesa com banquinhos
        { prop: "stove",   place: PG_PLACE.WALL_TOP,  lo: 1, hi: 1 },
        { prop: "cabinet", place: PG_PLACE.WALL_ROW,  lo: 4, hi: 6 },
        { prop: "table",   place: PG_PLACE.CENTER,    lo: 1, hi: 1, flank: "stool" },
        { prop: "cabinet", place: PG_PLACE.WALL_SIDE, lo: 1, hi: 2 },
        { prop: "shelf",   place: PG_PLACE.WALL_SIDE, lo: 1, hi: 1 },
        { prop: "barrel",  place: PG_PLACE.CORNER,    lo: 1, hi: 2 }
    ];
    _p[PG_ROOM.BATHROOM] = [ // banheiro: vaso na parede, armários, planta
        { prop: "toilet",  place: PG_PLACE.WALL_TOP,  lo: 1, hi: 1 },
        { prop: "cabinet", place: PG_PLACE.WALL_ROW,  lo: 2, hi: 3 },
        { prop: "cabinet", place: PG_PLACE.WALL_SIDE, lo: 1, hi: 1 },
        { prop: "plant",   place: PG_PLACE.CORNER,    lo: 1, hi: 2 }
    ];
    _p[PG_ROOM.DINING] = [ // sala de jantar: mesa grande no meio com cadeiras, aparadores na parede
        { prop: "table",   place: PG_PLACE.CENTER,    lo: 1, hi: 1, flank: "stool" },
        { prop: "cabinet", place: PG_PLACE.WALL_ROW,  lo: 3, hi: 4 },
        { prop: "shelf",   place: PG_PLACE.WALL_ROW,  lo: 1, hi: 2 },
        { prop: "cabinet", place: PG_PLACE.WALL_SIDE, lo: 1, hi: 2 },
        { prop: "plant",   place: PG_PLACE.CORNER,    lo: 2, hi: 3 }
    ];
    _p[PG_ROOM.OFFICE] = [ // escritório: mesa na parede com cadeira, estantes de livros
        { prop: "table",   place: PG_PLACE.WALL_TOP,  lo: 1, hi: 1, flank: "stool" },
        { prop: "shelf",   place: PG_PLACE.WALL_ROW,  lo: 4, hi: 6 },
        { prop: "shelf",   place: PG_PLACE.WALL_SIDE, lo: 2, hi: 3 },
        { prop: "cabinet", place: PG_PLACE.WALL_SIDE, lo: 1, hi: 1 },
        { prop: "plant",   place: PG_PLACE.CORNER,    lo: 1, hi: 2 },
        { prop: "chest",   place: PG_PLACE.CORNER,    lo: 0, hi: 1 }
    ];
    _p[PG_ROOM.STORAGE] = [ // despensa: prateleiras, barris e baús nas paredes e cantos
        { prop: "shelf",   place: PG_PLACE.WALL_ROW,  lo: 4, hi: 6 },
        { prop: "barrel",  place: PG_PLACE.CORNER,    lo: 2, hi: 4 },
        { prop: "chest",   place: PG_PLACE.CORNER,    lo: 1, hi: 2 },
        { prop: "barrel",  place: PG_PLACE.WALL_SIDE, lo: 2, hi: 3 },
        { prop: "chest",   place: PG_PLACE.WALL_SIDE, lo: 1, hi: 2 },
        { prop: "cabinet", place: PG_PLACE.WALL_SIDE, lo: 1, hi: 1 }
    ];
    return _p;
}

// andar atual e número de salas dele (5, 7, 9)
function procgen_floor() {
    if (!variable_global_exists("pg_floor")) global.pg_floor = 1;
    return clamp(global.pg_floor, 1, 3);
}
function procgen_floor_rooms(_f) {
    return 5 + 2 * (_f - 1);
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

    for (var _i = 0; _i < array_length(_rooms); _i++) {
        var _r = _rooms[_i];
        _r.idx   = _i;
        _r.links = []; // índices das salas ligadas por porta
        _r.type  = PG_ROOM.BEDROOM;
        _r.cx    = _r.x + _r.w div 2; // célula central
        _r.cy    = _r.y + _r.h div 2;
        _r.area  = (_r.w - 2) * (_r.h - 2); // área interna 
        _r.dist  = -1; // distância até a entrada
    }

    var _plan = {
        cols: _cfg.cols, rows: _cfg.rows,
        grid:  ds_grid_create(_cfg.cols, _cfg.rows),
        decor: ds_grid_create(_cfg.cols, _cfg.rows),
        rug:   ds_grid_create(_cfg.cols, _cfg.rows),
        root: _bsp.root, inner: _bsp.inner, rooms: _rooms,
        doors: [],
        start: undefined, goal: undefined, // entrada e saída 
        seed: 0, attempt: 0,
        ox: 0, oy: 0, cell: _cfg.cell,
        mismatch: []
    };
    ds_grid_clear(_plan.decor, 0);
    ds_grid_clear(_plan.rug, 0);

    procgen_carve(_plan); // paredes e chão
    if (!procgen_connect(_plan, _cfg)) { procgen_destroy(_plan); return undefined; }  
    procgen_assign_roles(_plan);
    if (!procgen_validate(_plan)) { procgen_destroy(_plan); return undefined; }

    // decoração
    var _ok = false;
    for (var _t = 0; _t < 12 && !_ok; _t++) {
        ds_grid_clear(_plan.decor, 0);
        ds_grid_clear(_plan.rug, 0);
        procgen_decorate(_plan, _cfg);
        _ok = procgen_validate_decor(_plan);
    }
    if (!_ok) ds_grid_clear(_plan.decor, 0);
    return _plan;
}

function procgen_destroy(_plan) {
    if (is_undefined(_plan)) return;
    if (ds_exists(_plan.grid,  ds_type_grid)) ds_grid_destroy(_plan.grid);
    if (ds_exists(_plan.decor, ds_type_grid)) ds_grid_destroy(_plan.decor);
    if (ds_exists(_plan.rug,   ds_type_grid)) ds_grid_destroy(_plan.rug);
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
        ds_grid_set_region(_plan.grid, _r.x + 1, _r.y + 1, _r.x + _r.w - 2, _r.y + _r.h - 2, PG_TILE.FLOOR);
    }
}


// ============================================================================
// PORTAS
// ============================================================================

function procgen_shared_wall(_a, _b) {
    var _ax2 = _a.x + _a.w - 1, _ay2 = _a.y + _a.h - 1;
    var _bx2 = _b.x + _b.w - 1, _by2 = _b.y + _b.h - 1;

    if (_ax2 == _b.x || _bx2 == _a.x) { // parede vertical
        var _ylo = max(_a.y, _b.y) + 1;
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
    var _len = min(_dw, _w.hi - _w.lo + 1);
    var _p   = irandom_range(_w.lo, _w.hi - _len + 1);

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

    // portas extras entre salas vizinhas ainda não ligadas
    var _rooms = _plan.rooms;
    for (var _i = 0; _i < array_length(_rooms); _i++) {
        for (var _j = _i + 1; _j < array_length(_rooms); _j++) {
            if (procgen_in(_rooms[_i].links, _j)) continue;
            if (random(1) >= _cfg.loop_chance) continue;
            var _ew = procgen_shared_wall(_rooms[_i], _rooms[_j]);
            if (!is_undefined(_ew)) procgen_add_door(_plan, _rooms[_i], _rooms[_j], _ew, _cfg.door_width);
        }
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

    // cômodos
    _start.type = PG_ROOM.LIVING;

    var _bath = undefined;
    if (_n >= 3) {
        for (var _i = 0; _i < _n; _i++) {
            var _r = _rooms[_i];
            if (_r == _start || _r == _goal) continue;
            if (is_undefined(_bath) || _r.area < _bath.area) _bath = _r;
        }
        if (!is_undefined(_bath)) _bath.type = PG_ROOM.BATHROOM;
    }

    var _kit = undefined;
    for (var _k = 0; _k < array_length(_start.links); _k++) {
        var _r = _rooms[_start.links[_k]];
        if (_r == _bath || _r == _goal) continue;
        if (is_undefined(_kit) || _r.area > _kit.area) _kit = _r;
    }
    if (is_undefined(_kit)) { // fallback: qualquer vizinha
        for (var _k = 0; _k < array_length(_start.links); _k++) {
            var _r = _rooms[_start.links[_k]];
            if (_r != _bath) { _kit = _r; break; }
        }
    }
    if (!is_undefined(_kit)) _kit.type = PG_ROOM.KITCHEN;

    // as mais perto da entrada viram (jantar -> escritório -> despensa)
    // o resto fica como quarto (longe da entrada)
    var _rest = [];
    for (var _i = 0; _i < _n; _i++) {
        var _r = _rooms[_i];
        if (_r != _start && _r != _bath && _r != _kit) array_push(_rest, _r);
    }
    array_sort(_rest, function(_a, _b) { return (_a.dist != _b.dist) ? (_a.dist - _b.dist) : (_b.area - _a.area); });

    var _extras = clamp(array_length(_rest) - 2, 0, 3); // sempre sobram >= 2 quartos
    var _kinds = [PG_ROOM.DINING, PG_ROOM.OFFICE, PG_ROOM.STORAGE];

    // sala de jantar: de preferência colada na cozinha
    if (_extras > 0 && !is_undefined(_kit)) {
        for (var _i = 0; _i < _extras; _i++) {
            if (procgen_in(_kit.links, _rest[_i].idx)) {
                var _t = _rest[0]; _rest[0] = _rest[_i]; _rest[_i] = _t;
                break;
            }
        }
    }
    for (var _i = 0; _i < _extras; _i++) _rest[_i].type = _kinds[_i];
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


// depois da decoração, verifica se o chão está livre e a saída ainda é alcançável
function procgen_validate_decor(_plan) {
    var _cols = _plan.cols, _rows = _plan.rows, _grid = _plan.grid, _decor = _plan.decor;

    var _total = 0;
    for (var _x = 0; _x < _cols; _x++)
        for (var _y = 0; _y < _rows; _y++)
            if (ds_grid_get(_grid, _x, _y) != PG_TILE.WALL && ds_grid_get(_decor, _x, _y) == 0) _total++;

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
            if (_seen[_q] || ds_grid_get(_grid, _nx, _ny) == PG_TILE.WALL || ds_grid_get(_decor, _nx, _ny) > 0) continue;
            _seen[_q] = true;
            array_push(_stack, _q);
        }
    }
    return (_count == _total) && _seen[_plan.goal.cx + _plan.goal.cy * _cols];
}


// ============================================================================
// DECORAÇÃO
// ============================================================================
function procgen_decorate(_plan, _cfg) {
    var _presets = procgen_presets();

    for (var _i = 0; _i < array_length(_plan.rooms); _i++) {
        var _r = _plan.rooms[_i];
        procgen_rug(_plan, _cfg, _r);

        var _rules = _presets[_r.type];
        for (var _k = 0; _k < array_length(_rules); _k++) {
            var _rule = _rules[_k];
            if (!variable_struct_exists(_cfg.props, _rule.prop)) continue;
            var _want = irandom_range(_rule.lo, _rule.hi);
            if (_want <= 0) continue;

            if (_rule.place == PG_PLACE.WALL_ROW) {
                procgen_place_row(_plan, _cfg, _r, _rule.prop, _want);
                continue;
            }

            var _cells = procgen_place_candidates(_r, _rule.place);
            procgen_shuffle(_cells);

            var _placed = 0;
            for (var _c = 0; _c < array_length(_cells) && _placed < _want; _c++) {
                var _cx = _cells[_c][0], _cy = _cells[_c][1];
                if (!procgen_decor_ok(_plan, _cx, _cy)) continue;
                ds_grid_set(_plan.decor, _cx, _cy, procgen_prop(_cfg, _rule.prop));
                _placed++;

                if (variable_struct_exists(_rule, "flank")) { // banquinhos dos dois lados da mesa
                    for (var _s = -1; _s <= 1; _s += 2) {
                        if (procgen_cell_free(_plan, _cx + _s, _cy)) ds_grid_set(_plan.decor, _cx + _s, _cy, procgen_prop(_cfg, _rule.flank));
                    }
                }
            }
        }
    }
}

// valor do prop 
function procgen_prop(_cfg, _name) {
    var _v = variable_struct_get(_cfg.props, _name);
    return is_array(_v) ? _v[irandom(array_length(_v) - 1)] : _v;
}

// tapete 3x3 esticado, centralizado e menor que a sala
function procgen_rug(_plan, _cfg, _r) {
    var _sets = _cfg.rugs[_r.type];
    if (array_length(_sets) == 0) return;

    var _iw = _r.w - 2, _ih = _r.h - 2;
    var _rw = max(3, floor(_iw * _cfg.rug_scale));
    var _rh = max(3, floor(_ih * _cfg.rug_scale));
    if (_rw > _iw - 2 || _rh > _ih - 2) return; // sem margem de chão

    var _set = _sets[irandom(array_length(_sets) - 1)];
    var _x0 = _r.x + 1 + (_iw - _rw) div 2;
    var _y0 = _r.y + 1 + (_ih - _rh) div 2;
    for (var _i = 0; _i < _rw; _i++) {
        for (var _j = 0; _j < _rh; _j++) {
            var _col = (_i == 0) ? 0 : ((_i == _rw - 1) ? 2 : 1);
            var _row = (_j == 0) ? 0 : ((_j == _rh - 1) ? 2 : 1);
            ds_grid_set(_plan.rug, _x0 + _i, _y0 + _j, _set[_row * 3 + _col]);
        }
    }
}

// fileira de objetos colados na parede de cima
function procgen_place_row(_plan, _cfg, _r, _prop, _n) {
    var _x0 = _r.x + 1, _x1 = _r.x + _r.w - 2, _y = _r.y + 1;
    var _len = min(_n, _x1 - _x0 + 1);

    for (var _t = 0; _t < 12; _t++) {
        var _sx = irandom_range(_x0, _x1 - _len + 1);
        var _ok = true;
        for (var _i = 0; _i < _len && _ok; _i++) _ok = procgen_decor_ok(_plan, _sx + _i, _y);
        if (!_ok) continue;
        for (var _i = 0; _i < _len; _i++) ds_grid_set(_plan.decor, _sx + _i, _y, procgen_prop(_cfg, _prop));
        return;
    }
}

function procgen_place_candidates(_r, _place) {
    var _x0 = _r.x + 1, _y0 = _r.y + 1;
    var _x1 = _r.x + _r.w - 2, _y1 = _r.y + _r.h - 2;
    var _out = [];

    switch (_place) {
        case PG_PLACE.WALL_TOP:
            for (var _x = _x0; _x <= _x1; _x++) array_push(_out, [_x, _y0]);
        break;
        case PG_PLACE.WALL_SIDE: // encostado na parede esquerda ou direita
            for (var _y = _y0; _y <= _y1; _y++) array_push(_out, [_x0, _y], [_x1, _y]);
        break;
        case PG_PLACE.CORNER:
            array_push(_out, [_x0, _y0], [_x1, _y0], [_x0, _y1], [_x1, _y1]);
        break;
        case PG_PLACE.CENTER:
            for (var _dx = -1; _dx <= 1; _dx++)
                for (var _dy = -1; _dy <= 1; _dy++) array_push(_out, [_r.cx + _dx, _r.cy + _dy]);
        break;
        default:
            for (var _x = _x0; _x <= _x1; _x++)
                for (var _y = _y0; _y <= _y1; _y++) array_push(_out, [_x, _y]);
        break;
    }
    return _out;
}

// chão livre, sem porta por perto, fora da entrada e da saída
function procgen_cell_free(_plan, _x, _y) {
    if (ds_grid_get(_plan.grid, _x, _y) != PG_TILE.FLOOR) return false;
    if (ds_grid_get(_plan.decor, _x, _y) != 0) return false;

    for (var _dx = -1; _dx <= 1; _dx++) {
        for (var _dy = -1; _dy <= 1; _dy++) {
            var _nx = _x + _dx, _ny = _y + _dy;
            if (_nx < 0 || _ny < 0 || _nx >= _plan.cols || _ny >= _plan.rows) continue;
            if (ds_grid_get(_plan.grid, _nx, _ny) == PG_TILE.DOOR) return false;
        }
    }
    if (abs(_x - _plan.start.cx) <= 1 && abs(_y - _plan.start.cy) <= 1) return false;
    if (abs(_x - _plan.goal.cx)  <= 1 && abs(_y - _plan.goal.cy)  <= 1) return false;
    return true;
}

// além de livre, não encosta em outro objeto
function procgen_decor_ok(_plan, _x, _y) {
    if (!procgen_cell_free(_plan, _x, _y)) return false;
    for (var _dx = -1; _dx <= 1; _dx++) {
        for (var _dy = -1; _dy <= 1; _dy++) {
            if (abs(_dx) + abs(_dy) == 2) continue; // diagonal pode encostar
            if (ds_grid_get(_plan.decor, _x + _dx, _y + _dy) != 0) return false;
        }
    }
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
    var _mc = procgen_layer_map(_cfg.layer_collision);
    var _md = procgen_layer_map(_cfg.layer_decor);

    for (var _x = 0; _x < _plan.cols; _x++) {
        for (var _y = 0; _y < _plan.rows; _y++) {
            var _t = ds_grid_get(_plan.grid, _x, _y);
            var _tx = _ox + _x, _ty = _oy + _y;

            if (_t == PG_TILE.WALL) {
                if (_mw != -1) tilemap_set(_mw, procgen_wall_tile(_plan, _cfg, _x, _y), _tx, _ty);
                procgen_set_collision(_mc, _cfg, _tx, _ty);
            } else {
                var _rug = ds_grid_get(_plan.rug, _x, _y);
                var _ft = (_rug > 0) ? _rug : _cfg.tile_floor;
                if (_mf != -1 && _ft > 0) tilemap_set(_mf, _ft, _tx, _ty);

                var _dec = ds_grid_get(_plan.decor, _x, _y);
                if (_dec > 0) {
                    if (_md != -1) tilemap_set(_md, _dec, _tx, _ty);
                    if (_cfg.decor_blocks) procgen_set_collision(_mc, _cfg, _tx, _ty);
                }
            }
        }
    }
}

function procgen_verify_applied(_plan, _cfg, _ox, _oy) {
    _plan.mismatch = [];
    var _mc = procgen_layer_map(_cfg.layer_collision);
    if (_mc == -1) return 0;

    var _k = max(1, _cfg.cell div tilemap_get_tile_width(_mc));
    for (var _x = 0; _x < _plan.cols; _x++) {
        for (var _y = 0; _y < _plan.rows; _y++) {
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
    return (ds_grid_get(_plan.grid, _x, _y) == PG_TILE.WALL) ? 1 : 0;
}

// parede automática pelos 4 vizinhos
function procgen_wall_tile(_plan, _cfg, _x, _y) {
    if (_cfg.tile_wall > 0) return _cfg.tile_wall;

    var _m = procgen_is_wall(_plan, _x, _y - 1)
           + procgen_is_wall(_plan, _x + 1, _y) * 2
           + procgen_is_wall(_plan, _x, _y + 1) * 4
           + procgen_is_wall(_plan, _x - 1, _y) * 8;

    if (_m == 5) { // vertical reta
        if (_x == 0) return _cfg.wall_left;
        if (_x == _plan.cols - 1) return _cfg.wall_right;
    }
    if (_m == 10 && _y == 0) return _cfg.wall_top; // horizontal da borda de cima
    return _cfg.walls[_m];
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

// paredes e móveis no mp_grid do obj_manager
function procgen_sync_mp_grid(_plan, _cfg, _ox, _oy, _mp) {
    for (var _x = 0; _x < _plan.cols; _x++) {
        for (var _y = 0; _y < _plan.rows; _y++) {
            var _blocked = ds_grid_get(_plan.grid, _x, _y) == PG_TILE.WALL
                        || (_cfg.decor_blocks && ds_grid_get(_plan.decor, _x, _y) > 0);
            if (_blocked) mp_grid_add_cell(_mp, _ox + _x, _oy + _y);
        }
    }
}

// centro da célula em pixels
function procgen_cell_to_px(_cell_x, _cell_y, _cfg, _ox, _oy) {
    return [(_ox + _cell_x) * _cfg.cell + _cfg.cell div 2,
            (_oy + _cell_y) * _cfg.cell + _cfg.cell div 2];
}

// célula de chão livre dentro da sala
function procgen_random_free_cell(_plan, _r) {
    for (var _t = 0; _t < 30; _t++) {
        var _x = irandom_range(_r.x + 1, _r.x + _r.w - 2);
        var _y = irandom_range(_r.y + 1, _r.y + _r.h - 2);
        if (ds_grid_get(_plan.grid, _x, _y) == PG_TILE.FLOOR && ds_grid_get(_plan.decor, _x, _y) == 0) return [_x, _y];
    }
    return undefined;
}


// ============================================================================
//  DEBUG
// ============================================================================
function procgen_debug_draw(_plan, _px, _py, _s) {
    var _room_col = [make_color_rgb(70,110,160), make_color_rgb(110,150,90),
                     make_color_rgb(190,140,70), make_color_rgb(140,100,160),
                     make_color_rgb(200,200,90), make_color_rgb(90,170,170), make_color_rgb(150,120,100)];

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