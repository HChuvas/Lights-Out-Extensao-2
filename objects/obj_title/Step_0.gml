var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);
hover = point_in_rectangle(_mx, _my, btn_x - btn_w/2, btn_y - btn_h/2, btn_x + btn_w/2, btn_y + btn_h/2);

if ((hover && mouse_check_button_pressed(mb_left)) || keyboard_check_pressed(vk_enter))
{
    room_goto(r_show_room);
}

if (keyboard_check_pressed(vk_f11)) {
    window_set_fullscreen(!window_get_fullscreen());
}
if (keyboard_check_pressed(vk_escape) && window_get_fullscreen()) {
    window_set_fullscreen(false);
}