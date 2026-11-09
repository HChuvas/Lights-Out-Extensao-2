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
                    consumed: false,
                };

                show_debug_message("Item " + _name + " no slot " + string(i+1));

                return true;
            }
        }

        show_debug_message("Inventário cheio");
        return false;
    };
	
	item_use = function() {
        var _item = _items[selected_index];
        if (is_undefined(_item)) {
            show_debug_message("Slot selecionado está vazio");
            return;
        }

        show_debug_message("Usando " + _item.name);
        var _def = global.items[$ _item.name];
        Player.item_held = _item.name;
        if (_item.quantity > 0) _def.on_use(Player);

        if (_def.consumable) {
            _item.quantity -= 1;
            if (_item.quantity <= 0) 
            {
                if (_def.destroy_on_consume) 
                {
                    _items[selected_index] = undefined;
                }
                else
                {
                    _item.consumed = true;
                }
            }
        }
    };
	
	item_stop = function() {
        if (Player.item_held == "") return;
        global.items[$ Player.item_held].on_stop(Player);
        Player.item_held = "";
    };
	
	select_slot = function(_index) {
        if (_index>=0 && _index<array_length(_items)) {
            selected_index = _index;

            if (is_undefined(_items[selected_index])) {
                show_debug_message("Slot " + string(_index + 1) + " vazio");
            } else {
                show_debug_message(
                    "Selecionado: " + _items[selected_index].name
                );
            }
        }
    };
	
	toString = function() {
		return json_stringify(_items);
	}

}