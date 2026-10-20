draw_self();

// aperta F1 pra ver
if (keyboard_check(vk_f1) && grid != -1) {
    draw_set_alpha(0.4);
    mp_grid_draw(grid);
    draw_set_alpha(1);
}