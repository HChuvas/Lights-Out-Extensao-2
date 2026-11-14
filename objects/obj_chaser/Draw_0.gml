draw_self();

draw_enemy_over_world(
    x - sprite_xoffset * abs(image_xscale), y - sprite_yoffset * abs(image_yscale),
    x - sprite_xoffset * abs(image_xscale) + sprite_width,
    y - sprite_yoffset * abs(image_yscale) + sprite_height,
    bbox_bottom);
