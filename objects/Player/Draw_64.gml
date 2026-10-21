// tela preta da transição de sala
var _a = fade;
with (obj_stage_switch) _a = max(_a, alpha);

if (_a > 0)
{
    draw_set_alpha(_a);
    draw_set_color(c_black);
    draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
    draw_set_alpha(1);
    draw_set_color(c_white);
}

var health_remaining = clamp(life_points, 0, 3);
var heart_size = 32;
var heart_spacing = 8;
var margin = 24;

for (var heart_index = 0; heart_index < 3; heart_index++) {
    var heart_sprite = heart_index < health_remaining
        ? spr_moon_heart : spr_empty_moon_heart;
    var heart_x = margin + heart_index * (heart_size + heart_spacing);
    draw_sprite_stretched(heart_sprite, 0, heart_x, margin, heart_size, heart_size);
}