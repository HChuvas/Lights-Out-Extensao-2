if (keyboard_check_pressed(vk_f2)) debug_view = !debug_view;
if (keyboard_check_pressed(vk_f3)) {
    cfg.seed = -1;
	pg_drop_save(cfg.floor_n);
    room_restart();
}