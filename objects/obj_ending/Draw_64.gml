draw_set_alpha(alpha);
draw_set_color(c_black);
draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);

draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(c_white);
draw_set_alpha(clamp((alpha - 0.6) / 0.4, 0, 1));
draw_text_transformed(display_get_gui_width() / 2, display_get_gui_height() / 2, "Fim", 2, 2, 0);

draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
