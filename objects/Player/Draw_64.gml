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
