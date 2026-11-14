// Desenha sprites em pixels inteiros para evitar stutters da câmera
//draw_sprite_ext(sprite_index, image_index, round(x), round(y), image_xscale, image_yscale, 0, c_white, image_alpha);

var visual_sprite = sprite_index;
var visual_frame = image_index;

if (socks_speed_timer > 0) {
    var normal_name = sprite_get_name(visual_sprite);
    var socks_name = string_replace(
        normal_name,
        "spr_kid_",
        "spr_kid_socks_"
    );
    // os sprites de andar da meia não têm "walk_" no nome (spr_kid_socks_down)
    socks_name = string_replace(socks_name, "walk_", "");
    var socks_sprite = asset_get_index(socks_name);

    if (sprite_exists(socks_sprite)) {
        visual_sprite = socks_sprite;
    }
}

if (consume_frame >= 0) {
    visual_sprite = spr_player_consume_item;
    visual_frame = floor(consume_frame);
}

draw_sprite_ext(
    visual_sprite, visual_frame,
    x, y,
    image_xscale, image_yscale,
    0, c_white, image_alpha
);

// Redesenha o pedaço do móvel que cobre o player
if (variable_global_exists("pg_front") && global.pg_front_room == room) {
    var _feet = bbox_bottom;
    var _pl = x - sprite_get_xoffset(visual_sprite) * abs(image_xscale);
    var _pt = y - sprite_get_yoffset(visual_sprite) * abs(image_yscale);
    var _pr = _pl + sprite_get_width(visual_sprite) * abs(image_xscale);
    var _pb = _pt + sprite_get_height(visual_sprite) * abs(image_yscale);

    var _fl = global.pg_front;
    for (var _i = 0; _i < array_length(_fl); _i++) {
        var _f = _fl[_i];
        if (_f.base <= _feet) continue; // player está na frente
        var _il = max(_pl, _f.x), _it = max(_pt, _f.y);
        var _ir = min(_pr, _f.x + _f.w), _ib = min(_pb, _f.y + _f.h);
        if (_ir <= _il || _ib <= _it) continue; // não encosta no player
        draw_sprite_part(_f.spr, 0, _il - _f.x, _it - _f.y, _ir - _il, _ib - _it, _il, _it);
    }
}

// paredes desenhadas por cima do player
var _wmaps = [];
var _wnames = ["Walls", "WallLayer"];
for (var _wn = 0; _wn < array_length(_wnames); _wn++) {
    if (layer_exists(_wnames[_wn])) {
        var _wlm = layer_tilemap_get_id(_wnames[_wn]);
        if (_wlm != -1) array_push(_wmaps, _wlm);
    }
}
if (variable_global_exists("pg_frames_map") && global.pg_front_room == room && global.pg_frames_map != -1) array_push(_wmaps, global.pg_frames_map);

var _wfeet = bbox_bottom;
var _wl = x - sprite_get_xoffset(visual_sprite) * abs(image_xscale);
var _wt = y - sprite_get_yoffset(visual_sprite) * abs(image_yscale);
var _wr = _wl + sprite_get_width(visual_sprite) * abs(image_xscale);
var _wb = _wt + sprite_get_height(visual_sprite) * abs(image_yscale);

for (var _m = 0; _m < array_length(_wmaps); _m++) {
    var _wm = _wmaps[_m];
    var _wtw = tilemap_get_tile_width(_wm), _wth = tilemap_get_tile_height(_wm);
    var _wmx = tilemap_get_x(_wm), _wmy = tilemap_get_y(_wm);
    var _wts = tilemap_get_tileset(_wm);

    var _cx0 = floor((_wl - _wmx) / _wtw), _cx1 = floor((_wr - 1 - _wmx) / _wtw);
    var _cy0 = floor((_wt - _wmy) / _wth), _cy1 = floor((_wb - 1 - _wmy) / _wth);
    for (var _cx = _cx0; _cx <= _cx1; _cx++) {
        for (var _cy = _cy0; _cy <= _cy1; _cy++) {
            var _td = tilemap_get(_wm, _cx, _cy);
            if (_td == -1 || tile_get_index(_td) == 0) continue;
            if (_wmy + (_cy + 1) * _wth <= _wfeet) {
                // parede acima dos pés
                var _fd = tilemap_get(_wm, _cx, floor((_wfeet - _wmy) / _wth));
                if (_fd == -1 || tile_get_index(_fd) == 0) continue;
            }
            draw_tile(_wts, _td, 0, _wmx + _cx * _wtw, _wmy + _cy * _wth);
        }
    }
}
