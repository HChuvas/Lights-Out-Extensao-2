var slot_size = 48;
var gap = 4;

var total_width = slot_size * 2 + gap;
var start_x = (display_get_gui_width() - total_width) / 2;
var start_y = display_get_gui_height() - slot_size - 20;

for (var i = 0; i < 2; i++) {
    var slot_x = start_x + i * (slot_size + gap);
    var slot_y = start_y;

    draw_set_color(make_color_rgb(105, 65, 40));
    draw_rectangle(
        slot_x, slot_y,
        slot_x + slot_size, slot_y + slot_size,
        false
    );

    if (i == inventory.selected_index) {
        draw_set_color(c_yellow);
    } else {
        draw_set_color(make_color_rgb(190, 140, 95));
    }

    draw_rectangle(
        slot_x, slot_y,
        slot_x + slot_size, slot_y + slot_size,
        true
    );
	
	if (!is_undefined(inventory._items[i])) {
	    var item_sprite = inventory._items[i].sprite;

	    var sprite_w = sprite_get_width(item_sprite);
	    var sprite_h = sprite_get_height(item_sprite);

	    var padding = 2;
	    var max_size = slot_size - padding * 2;
	    var scale = min(max_size / sprite_w, max_size / sprite_h);

	    var origin_x = sprite_get_xoffset(item_sprite);
	    var origin_y = sprite_get_yoffset(item_sprite);

	    var draw_x = slot_x + (slot_size - sprite_w * scale) / 2
	                 + origin_x * scale;

	    var draw_y = slot_y + (slot_size - sprite_h * scale) / 2
	                 + origin_y * scale;

	    draw_sprite_ext(
	        item_sprite, 0,
	        draw_x, draw_y,
	        scale, scale,
	        0, c_white, 1
	    );
	}
}

draw_set_color(c_white);
