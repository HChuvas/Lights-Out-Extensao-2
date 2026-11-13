if (keyboard_check_pressed(vk_f2)) global.pg_debug_view = !global.pg_debug_view;
if (keyboard_check_pressed(vk_f3)) {
    cfg.seed = -1;
	pg_drop_save(cfg.floor_n);
    room_restart();
}

// cliques nos botões do mapa de debug
if (global.pg_debug_view && !is_undefined(plan) && mouse_check_button_pressed(mb_left)) {
    var _mx = device_mouse_x_to_gui(0), _my = device_mouse_y_to_gui(0);
    for (var _i = 0; _i < array_length(debug_buttons); _i++) {
        var _r = debug_btn_rect(_i);
        if (point_in_rectangle(_mx, _my, _r[0], _r[1], _r[2], _r[3])) {
            debug_buttons[_i].action();
            break;
        }
    }
}