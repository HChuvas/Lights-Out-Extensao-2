draw_self();

// aperta F1 pra ver
if (keyboard_check(vk_f1)) {
    draw_set_alpha(0.4);
    mp_grid_draw(global.grid_safe);
    draw_set_alpha(1);
}