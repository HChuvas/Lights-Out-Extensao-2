if (id != instance_find(obj_controller, 0)) exit;

if (keyboard_check_pressed(vk_f11)) {
    window_set_fullscreen(!window_get_fullscreen());
}
if (keyboard_check_pressed(vk_escape) && window_get_fullscreen()) {
    window_set_fullscreen(false);
}