// Alinha o corpo do sprite com a máscara
var _s = sprite_index;
var _dx = mask_cx - ((sprite_get_bbox_left(_s) + sprite_get_bbox_right(_s)) / 2 - sprite_get_xoffset(_s));
var _dy = mask_bottom - (sprite_get_bbox_bottom(_s) - sprite_get_yoffset(_s));
draw_sprite_ext(_s, image_index, x + _dx, y + _dy, image_xscale, image_yscale, image_angle, image_blend, image_alpha);

// aperta F1 pra ver
if (keyboard_check(vk_f1) && grid != -1) {
    draw_set_alpha(0.4);
    mp_grid_draw(grid);
    draw_set_alpha(1);
}