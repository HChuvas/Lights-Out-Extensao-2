draw_self();
if (state == WARDROBE_STATES.WAITING) gap_draw();

// F1 mostra a área de troca
if (keyboard_check(vk_f1)) {
    draw_set_alpha(0.25);
    draw_set_color(c_lime);
    draw_rectangle(bbox_left - area_margin_x, bbox_top - area_margin_top,
                   bbox_right + area_margin_x, bbox_bottom + area_margin_bottom, false);
    draw_set_alpha(1);
    draw_set_color(c_white);
}
