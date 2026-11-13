// tela preta da transição de sala
var _a = fade;
with (obj_stage_switch) _a = max(_a, alpha);

if (_a > 0)
{
    draw_set_alpha(_a);
    draw_set_color(c_black);
    draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
    draw_set_alpha(1);
    draw_set_color(c_white);
}

// texto de interação em cima do objeto
var _cam = view_camera[0];
var _scale = display_get_gui_width() / camera_get_view_width(_cam);
draw_set_halign(fa_center);
draw_set_valign(fa_bottom);
draw_set_colour(c_white);

// [F] pegar / interagir
if (instance_exists(target) && item_held == "")
{
	var _gx = ((target.bbox_left + target.bbox_right) / 2 - camera_get_view_x(_cam)) * _scale;
	var _gy = (target.bbox_top - camera_get_view_y(_cam)) * _scale;
	draw_text(_gx, _gy - 4, "[F] " + target.prompt);
}

// [G] soltar o item para trocar com o armário
if (!frozen && item_held == "" && instance_exists(obj_inventory) && pg_phase() >= 1 && !instance_exists(obj_blackout))
{
	var _inv = obj_inventory.inventory;
	var _slot = _inv._items[_inv.selected_index];
	if (!is_undefined(_slot))
	{
		// ponto onde o item cairia
		var _px = (bbox_left + bbox_right) / 2;
		var _py = (bbox_top + bbox_bottom) / 2;
		switch (facing)
		{
			case "right": _px = bbox_right + 8;  break;
			case "left":  _px = bbox_left - 8;   break;
			case "down":  _py = bbox_bottom + 8; break;
			case "up":    _py = bbox_top - 8;    break;
		}
		var _w = noone;
		with (obj_wardrobe)
		{
			if (state == WARDROBE_STATES.WAITING && in_trade_area(_px, _py)) { _w = id; break; }
		}
		if (_w != noone)
		{
			var _wx = ((_w.bbox_left + _w.bbox_right) / 2 - camera_get_view_x(_cam)) * _scale;
			var _wy = (_w.bbox_top - camera_get_view_y(_cam)) * _scale;
			draw_text(_wx, _wy - 4, "[G] Soltar para trocar");
		}
	}
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);