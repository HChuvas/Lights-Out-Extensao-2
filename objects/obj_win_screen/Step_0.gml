var mouse_gui_x = device_mouse_x_to_gui(0);
var mouse_gui_y = device_mouse_y_to_gui(0);
hover = point_in_rectangle(mouse_gui_x, mouse_gui_y, btn_x - btn_w/2, btn_y - btn_h/2, btn_x + btn_w/2, btn_y + btn_h/2);

if ((hover && mouse_check_button_pressed(mb_left)) || keyboard_check_pressed(vk_enter)) {
<<<<<<< HEAD
    global.pg_floor = 1;
	pg_clear_saves();
    room_goto(r_procedural);
=======
    global.pg_floor = 3;
	pg_clear_saves();
    room_goto(r_starting_room);
>>>>>>> 4e1a21a98f2237d2770fbcc4c83d62420580492b
}

if (keyboard_check_pressed(vk_f11)) {
    window_set_fullscreen(!window_get_fullscreen());
}
if (keyboard_check_pressed(vk_escape) && window_get_fullscreen()) {
    window_set_fullscreen(false);
}