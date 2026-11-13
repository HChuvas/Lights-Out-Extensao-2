
function Inventory () constructor{
	
	_items = array_create(2, undefined);
	selected_index = 0;
	
    item_add = function(_name, _quantity) {
        if (is_undefined(global.items[$ _name])) {
            show_debug_message("Item não existe: " + _name);
            return false;
        }

        for (var i = 0; i < array_length(_items); i++) {
            if (is_undefined(_items[i])) {
                _items[i] = {
                    name: _name,
                    quantity: _quantity,
                    consumed: (_quantity <= 0),
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
            show_debug_message("Item sem cargas disponíveis");
            return false;
        }

        var _def = global.items[$ _item.name];
        if (!_def.usable) {
            show_debug_message("Item não utilizável no momento");
            return false;
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
	
    select_slot = function(_index) {
        if (_index >= 0 && _index < array_length(_items)) {
            
            if (Player.item_held != "") {
            item_stop();
        }
            selected_index = _index;

            if (is_undefined(_items[selected_index])) {
                show_debug_message("Slot " + string(_index + 1) + " vazio");
            } else {
                show_debug_message("Selecionado: " + _items[selected_index].name);
            }
        }
    };
	
    toString = function() {
        return json_stringify(_items);
    }
}
