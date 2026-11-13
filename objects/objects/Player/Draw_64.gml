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

// texto de interação em cima do objeto
if (instance_exists(target))
{
	var _cam = view_camera[0];
	var _scale = display_get_gui_width() / camera_get_view_width(_cam);
	var _gx = ((target.bbox_left + target.bbox_right) / 2 - camera_get_view_x(_cam)) * _scale;
	var _gy = (target.bbox_top - camera_get_view_y(_cam)) * _scale;
	draw_set_halign(fa_center);
	draw_set_valign(fa_bottom);
	draw_set_colour(c_white);
	draw_text(_gx, _gy - 4, "[F] " + target.prompt);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
}
