// mapa de debug do plano
if (!global.pg_debug_view || is_undefined(plan)) exit;

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_alpha(0.7);
draw_set_color(c_black);
draw_rectangle(8, 8, 8 + cfg.cols * debug_scale + 8, 8 + cfg.rows * debug_scale + 24, false);
draw_set_alpha(1);
procgen_debug_draw(plan, 12, 12, debug_scale);
draw_set_color(c_white);

// botões de pular fase
var _mx = device_mouse_x_to_gui(0), _my = device_mouse_y_to_gui(0);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
for (var _i = 0; _i < array_length(debug_buttons); _i++) {
    var _r = debug_btn_rect(_i);
    var _hover = point_in_rectangle(_mx, _my, _r[0], _r[1], _r[2], _r[3]);
    draw_set_alpha(0.85);
    draw_set_color(_hover ? make_colour_rgb(90, 90, 90) : c_black);
    draw_rectangle(_r[0], _r[1], _r[2], _r[3], false);
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_rectangle(_r[0], _r[1], _r[2], _r[3], true);
    var _txt = variable_struct_exists(debug_buttons[_i], "get_label") ? debug_buttons[_i].get_label() : debug_buttons[_i].label;
    var _sc = min(0.6, (_r[2] - _r[0] - 6) / max(1, string_width(_txt))); // encolhe pra caber no botão
    draw_text_transformed((_r[0] + _r[2]) / 2, (_r[1] + _r[3]) / 2, _txt, _sc, _sc, 0);
}
draw_set_halign(fa_left);
draw_set_valign(fa_top);


