// brilho pra indicar o lanche
glow_t += 2;
var _a = 0.18 + 0.1 * sin(degtorad(glow_t * 3));
var _cx = x - sprite_get_xoffset(sprite_index) + sprite_get_width(sprite_index) / 2;
var _cy = y - sprite_get_yoffset(sprite_index) + sprite_get_height(sprite_index) / 2;
gpu_set_blendmode(bm_add);
draw_set_color(make_colour_rgb(255, 210, 120));
draw_set_alpha(_a);
draw_circle(_cx, _cy, 9, false);
draw_set_alpha(_a * 0.6);
draw_circle(_cx, _cy, 5, false);
gpu_set_blendmode(bm_normal);
draw_set_alpha(1);
draw_set_color(c_white);
draw_self();