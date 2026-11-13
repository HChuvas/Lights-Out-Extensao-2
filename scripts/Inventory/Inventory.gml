function Inventory () constructor {
	
	_items = array_create(2, undefined);
	selected_index = 0;
	msg = ""; // aviso curto na tela
	msg_timer = 0;

    item_add = function(_name, _quantity, _consumed = false) {
        if (is_undefined(global.items[$ _name])) {
            show_debug_message("Item não existe: " + _name);
            return false;
        }

        for (var i = 0; i < array_length(_items); i++) {
            if (is_undefined(_items[i])) {
                _items[i] = {
                    name: _name,
                    quantity: _quantity,
                    consumed: _consumed,
                };

                show_debug_message("Item " + _name + " no slot " + string(i+1));
                return true;
            }
        }

        show_debug_message("Inventário cheio");
        return false;
    };
	
    item_use = function() {
        if (Player.item_held != "") {
            return false;
        }

        var _item = _items[selected_index];
        if (is_undefined(_item)) {
            show_debug_message("Slot vazio");
            return false;
        }

        if (_item.quantity <= 0) {
            _item.consumed = true;
            msg = "Sem carga";
            msg_timer = 90;
            show_debug_message("Item sem cargas disponíveis");
            return false;
        }

        var _def = global.items[$ _item.name];
        if (!_def.usable) {
            show_debug_message("Item não utilizável no momento");
            if (variable_struct_exists(_def, "blocked_msg")) {
                msg = _def.blocked_msg;
                msg_timer = 90;
            }
            return;
        }

        var _activated = _def.on_use(Player);
        if (_activated == false) {
            return false;
        }

        Player.item_held = _item.name;
        show_debug_message("Usando " + _item.name);

        if (_def.consumable) {
            _item.quantity = max(0, _item.quantity - 1);

            if (_item.quantity <= 0) {
                _item.consumed = true;

                if (_def.destroy_on_consume) {
                    _items[selected_index] = undefined;
                }
            }
        }

        return true;
    };
	
    item_stop = function() {
        if (Player.item_held == "") return;

        var _item_name = Player.item_held;
        var _def = global.items[$ _item_name];

        if (!is_undefined(_def) && !is_undefined(_def.on_stop)) {
            _def.on_stop(Player);
        }

        Player.item_held = "";
    };
	
    item_check_availability = function() {
        var _item = _items[selected_index];
        if (is_undefined(_item)) return;

        var _def = global.items[$ _item.name];

        if (_def.check_availability != noone) {
            _def.check_availability(Player);
        }
    };
	
	// Larga o item do slot selecionado no chão
	item_drop = function() {
        var _item = _items[selected_index];
        if (is_undefined(_item)) {
            show_debug_message("Slot vazio, nada para largar");
            return false;
        }
        if (!instance_exists(Player)) return false;
        if (Player.frozen) return false;
        if (Player.item_held != "") return false; // está usando o item

        var _def = global.items[$ _item.name];
        if (!variable_struct_exists(_def, "pickup") || _def.pickup == noone) {
            show_debug_message("Item sem objeto de chão (pickup): " + _item.name);
            return false;
        }

        // centro do jogador e direção em que ele olha
        var _cx = (Player.bbox_left + Player.bbox_right) / 2;
        var _cy = (Player.bbox_top + Player.bbox_bottom) / 2;
        var _hw = (Player.bbox_right - Player.bbox_left) / 2;
        var _hh = (Player.bbox_bottom - Player.bbox_top) / 2;
        var _dx = 0, _dy = 0, _reach = 0;
        switch (Player.facing) {
            case "right": _dx =  1; _reach = _hw; break;
            case "left":  _dx = -1; _reach = _hw; break;
            case "down":  _dy =  1; _reach = _hh; break;
            case "up":    _dy = -1; _reach = _hh; break;
        }

        // posições candidatas
        var _dists = [8, 6, 4, 2, 0];
        var _solids = [Balloon];
        if (Player.wall_map != noone) array_push(_solids, Player.wall_map);
        if (Player.collision_map != noone) array_push(_solids, Player.collision_map);

        var _inst = instance_create_layer(_cx, _cy, "Instances", _def.pickup);
        _inst._name = _item.name;
        _inst._quantity = _item.quantity;
        _inst._consumed = _item.consumed;
        _inst._dropped = true; // só troca itens largados pelo jogador

        with (_inst) {
            for (var i = 0; i < array_length(_dists); i++) {
                x = round(_cx + _dx * (_reach + _dists[i]) - sprite_width / 2);
                y = round(_cy + _dy * (_reach + _dists[i]) - sprite_height / 2);
                if (!place_meeting(x, y, _solids)) break;
            }
        }

        _items[selected_index] = undefined;
        show_debug_message("Largou " + _item.name);
        return true;
    };
	
    select_slot = function(_index) {
        if (_index < array_length(_items)) {
            if (Player.item_held != "") {
                item_stop();
            }
            
            if (_index == -1) {
                selected_index = selected_index ? 0 : 1;
            } else {
                selected_index = _index;
            }

            if (is_undefined(_items[selected_index])) {
                show_debug_message("Slot " + string(selected_index + 1) + " vazio");
            } else {
                show_debug_message("Selecionado: " + _items[selected_index].name);
            }
        }
    };
	
	toString = function() {
		return json_stringify(_items);
	}
}

// ---------------------------------------------------------------------------
// Save para a sala final
// ---------------------------------------------------------------------------
function item_room_save() {
    if (room == r_procedural) return;
    if (!variable_global_exists("room_items")) global.room_items = {};

    var _list = [];
    with (obj_item_parent) {
        array_push(_list, {
            obj: object_index, x: x, y: y, depth: depth,
            name: _name, quantity: _quantity, consumed: _consumed, dropped: _dropped
        });
    }
    variable_struct_set(global.room_items, room_get_name(room), _list);
}

function item_room_restore() {
    if (room == r_procedural) return;
    if (!variable_global_exists("room_items")) return;

    var _list = variable_struct_get(global.room_items, room_get_name(room));
    if (is_undefined(_list)) return;   // sala nunca visitada

    // lista salva
    with (obj_item_parent) instance_destroy();

    for (var i = 0; i < array_length(_list); i++) {
        var _s = _list[i];
        var _inst = instance_create_layer(_s.x, _s.y, "Instances", _s.obj);
        _inst.depth = _s.depth;
        _inst._name = _s.name;
        _inst._quantity = _s.quantity;
        _inst._consumed = _s.consumed;
        _inst._dropped = _s.dropped;
    }
}