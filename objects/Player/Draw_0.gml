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