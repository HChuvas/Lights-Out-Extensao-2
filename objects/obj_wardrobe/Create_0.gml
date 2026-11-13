// Monstro do armário
enum WARDROBE_STATES { WAITING, TRADING, NOTHING }
state = WARDROBE_STATES.WAITING;

// ajustes
max_trades = 2;
give_frame = 5; // frame da animação de troca em que o item novo aparece
blink_time = [2, 4]; // segundos entre os brilhos de olhos
blink_len = 2.2; // duração de cada brilho
glow_speed = 0.035;
glow_a = 0; // intensidade atual do brilho 
area_margin_x = 24; // área de troca
area_margin_top = 4; // em cima
area_margin_bottom = 28; // frente

if (!variable_instance_exists(id, "el")) el = -1; // armários no mapa
if (!variable_instance_exists(id, "trades")) trades = 0; // trocas já feitas

// logo na frente da camada dos móveis
depth = 349;

received  = "";
give_name = "";
give_x = 0;
give_y = 0;
given = false;
blinking = false;
blink_t = 0;
timer = 0;

// o item está dentro da área de troca
in_trade_area = function(_x, _y) {
    if (!point_in_rectangle(_x, _y,
        bbox_left - area_margin_x, bbox_top - area_margin_top,
        bbox_right + area_margin_x, bbox_bottom + area_margin_bottom)) return false;

    // não troca através de parede
    var _fx = clamp(_x, bbox_left, bbox_right), _fy = clamp(_y, bbox_top, bbox_bottom);
    var _len = point_distance(_x, _y, _fx, _fy);
    if (_len > 4) {
        _fx = _x + (_fx - _x) * (_len - 3) / _len;
        _fy = _y + (_fy - _y) * (_len - 3) / _len;
        for (var _i = 0; _i < array_length(global.solid_maps); _i++) {
            if (collision_line(_x, _y, _fx, _fy, global.solid_maps[_i], false, true) != noone) return false;
        }
    }
    return true;
}

// primeiro item largado pelo jogador dentro da área
find_dropped_item = function() {
    var _found = noone;
    with (obj_item_parent) {
        if (!_dropped) continue;
        if (other.in_trade_area(x + sprite_width / 2, y + sprite_height / 2)) { _found = id; break; }
    }
    return _found;
}

// item aleatório
pick_item = function(_received) {
    var _names = variable_struct_get_names(global.items);
    var _pool = [];
    for (var i = 0; i < array_length(_names); i++) {
        var _def = global.items[$ _names[i]];
        if (_names[i] == _received) continue;
        if (!variable_struct_exists(_def, "pickup") || _def.pickup == noone) continue;
        array_push(_pool, _names[i]);
    }
    if (array_length(_pool) == 0) return _received;
    return _pool[irandom(array_length(_pool) - 1)];
}

set_idle = function() {
    sprite_index = spr_wardrobe_enemy_idle;
    image_index = 0;
    image_speed = 0;
    blinking = false;
    blink_t = 0;
    timer = irandom_range(blink_time[0], blink_time[1]) * game_get_speed(gamespeed_fps);
}

// olhos brilhando por cima da escuridão
glow_update = function() {
    var _target = 0;
    if (state == WARDROBE_STATES.WAITING && blinking) {
        // brilho só some nos últimos frames da piscada
        _target = (blink_t < blink_len * game_get_speed(gamespeed_fps) * 0.65) ? 1 : 0;
    }
    glow_a = lerp(glow_a, _target, glow_speed);
    if (_target == 0 && glow_a < 0.03) glow_a = 0;
}

gap_draw = function() {
    if (glow_a <= 0.03) return;
    var _e = glow_a * glow_a * (3 - 2 * glow_a);
    var _h = max(2, round(lerp(2, 14, _e)));
    var _top = y + 15 - round((_h - 2) * (4 / 12));
    var _x1 = (_e > 0.55) ? x + 13 : x + 14;
    var _x2 = (_e > 0.55) ? x + 16 : x + 15;
    draw_set_color(make_colour_rgb(14, 8, 10));
    draw_set_alpha(clamp(_e * 3, 0, 1));
    draw_rectangle(_x1, _top, _x2, _top + _h - 1, false);
    draw_set_alpha(1);
    draw_set_color(c_white);
}

// desenhar olhos brilhando por cima da escuridão
glow_draw = function() {
    if (!visible || glow_a <= 0) return;

    var _a = glow_a * glow_a * (3 - 2 * glow_a); // suaviza as pontas
    _a *= 0.92 + 0.08 * sin(current_time * 0.006);
    var _ex = x + 15, _ey = y + 16; // centro dos olhos

    gpu_set_blendmode(bm_add);
    draw_set_color(make_colour_rgb(255, 200, 90));
    for (var _i = 0; _i < 4; _i++) {
        draw_set_alpha(_a * 0.035);
        draw_circle(_ex, _ey, 3 + _i * 2.5, false);
    }
    gpu_set_blendmode(bm_normal);

    // olhos
    draw_set_color(make_colour_rgb(255, 232, 120));
    draw_set_alpha(_a * _a * 0.9); // os olhos acendem depois da fresta abrir
    draw_rectangle(x + 14, y + 15, x + 15, y + 16, false);

    draw_set_alpha(1);
    draw_set_color(c_white);
}

start_trade = function(_item) {
	blinking = false;
    received = _item._name;
    give_name = pick_item(received);
    give_x = _item.x;
    give_y = _item.y;
    given = false;
    with (_item) instance_destroy();

    state = WARDROBE_STATES.TRADING;
    sprite_index = spr_wardrobe_enemy_trade;
    image_index = 0;
    image_speed = 1;
}

// o item novo aparece onde o jogador largou o antigo
give_item = function() {
    if (given) return;
    given = true;
    var _def = global.items[$ give_name];
    var _inst = instance_create_layer(give_x, give_y, "Instances", _def.pickup);
    _inst._name = give_name;
}

become_normal = function() {
    state = WARDROBE_STATES.NOTHING;
    if (el != -1) layer_sprite_alpha(el, 1); // o armário original volta a aparecer
    visible = false;
}

finish_trade = function() {
    give_item(); // garante que o item saiu
    trades++;
    if (trades >= max_trades) become_normal();
    else {
        state = WARDROBE_STATES.WAITING;
        set_idle();
    }
}

// usado ao salvar o andar
flush_trade = function() {
    if (state == WARDROBE_STATES.TRADING) finish_trade();
}

if (trades >= max_trades) become_normal();
else {
    if (el != -1) layer_sprite_alpha(el, 0); // esconde o armário original
    set_idle();
}
