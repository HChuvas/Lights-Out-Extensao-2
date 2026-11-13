// mapa de debug do plano
if (!debug_view || is_undefined(plan)) exit;

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_alpha(0.7);
draw_set_color(c_black);
draw_rectangle(8, 8, 8 + cfg.cols * debug_scale + 8, 8 + cfg.rows * debug_scale + 24, false);
draw_set_alpha(1);
procgen_debug_draw(plan, 12, 12, debug_scale);
draw_set_color(c_white);


