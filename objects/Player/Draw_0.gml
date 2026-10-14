draw_sprite_ext(sprite_index, image_index, round(x), round(y), image_xscale, image_yscale, 0, c_white, 1);
draw_set_color(c_red);
draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, true);
draw_set_color(c_white);
