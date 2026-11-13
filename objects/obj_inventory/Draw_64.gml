var ui_scale = 2;
var slot_size = 24 * ui_scale;
var gap = 2 * ui_scale;

var total_width = sprite_get_width(spr_inventory_slots) * ui_scale;
var start_x = (display_get_gui_width() - total_width) / 2;
var start_y = display_get_gui_height() - slot_size - 20;

draw_sprite_ext(
    spr_inventory_slots, 0,
    start_x + sprite_get_xoffset(spr_inventory_slots) * ui_scale,
    start_y + sprite_get_yoffset(spr_inventory_slots) * ui_scale,
    ui_scale, ui_scale, 0, c_white, 1
);

for (var i = 0; i < 2; i++) {
    var slot_x = start_x + i * (slot_size + gap);
    var slot_y = start_y;

    if (i == inventory.selected_index) {
        draw_sprite_part_ext(
            spr_inventory_slots, 0,
            i * 26, 0, 24, 24,
            slot_x, slot_y,
            ui_scale, ui_scale, c_yellow, 1
        );
    }

    if (!is_undefined(inventory._items[i])) {
        var item = global.items[$ inventory._items[i].name];
        var item_sprite = inventory._items[i].consumed
            ? item.consumed_sprite : item.sprite;

        var sprite_w = sprite_get_width(item_sprite);
        var sprite_h = sprite_get_height(item_sprite);
        var padding = 4;
        var max_size = slot_size - padding * 2;
        var item_scale = min(ui_scale, min(max_size / sprite_w, max_size / sprite_h));

        var draw_x = slot_x + (slot_size - sprite_w * item_scale) / 2
            + sprite_get_xoffset(item_sprite) * item_scale;
        var draw_y = slot_y + (slot_size - sprite_h * item_scale) / 2
            + sprite_get_yoffset(item_sprite) * item_scale;

        draw_sprite_ext(
            item_sprite, 0, draw_x, draw_y,
            item_scale, item_scale, 0, c_white, 1
        );
    }
}

draw_set_color(c_white);

// aviso curto acima dos slots
if (inventory.msg_timer > 0) {
    inventory.msg_timer--;
    draw_set_halign(fa_center);
    draw_set_valign(fa_bottom);
    draw_set_alpha(min(1, inventory.msg_timer / 20));
    draw_set_color(c_white);
    draw_text(display_get_gui_width() / 2, start_y - 8, inventory.msg);
    draw_set_alpha(1);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
// dica do item selecionado
else if (instance_exists(Player) && Player.item_held == "") {
    var _sel = inventory._items[inventory.selected_index];
    if (!is_undefined(_sel)) {
        var _def = global.items[$ _sel.name];
        var _hint = variable_struct_exists(_def, "hint") ? _def.hint + "   " : "";
        if (_sel.quantity <= 0) _hint = "Sem carga   ";
        draw_set_halign(fa_center);
        draw_set_valign(fa_bottom);
        draw_set_alpha(0.8);
        draw_set_color(c_white);
        draw_text(display_get_gui_width() / 2, start_y - 8, _hint + "[G] Largar");
        draw_set_alpha(1);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
    }
}