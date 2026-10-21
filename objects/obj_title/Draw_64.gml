draw_set_halign(fa_center);
draw_set_valign(fa_middle);

draw_set_color(c_white);
draw_text_transformed(160, 60, "Light's Out", 2, 2, 0);

draw_set_color(hover ? c_yellow : c_white);
draw_rectangle(btn_x - btn_w/2, btn_y - btn_h/2, btn_x + btn_w/2, btn_y + btn_h/2, true);
draw_text(btn_x, btn_y, "Play");

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);