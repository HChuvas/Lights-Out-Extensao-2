var mouse_gui_x = device_mouse_x_to_gui(0);
var mouse_gui_y = device_mouse_y_to_gui(0);
hover = point_in_rectangle(mouse_gui_x, mouse_gui_y, btn_x - btn_w/2, btn_y - btn_h/2, btn_x + btn_w/2, btn_y + btn_h/2);

if ((hover && mouse_check_button_pressed(mb_left)) || keyboard_check_pressed(vk_enter)) {
    room_goto(r_show_room);
}