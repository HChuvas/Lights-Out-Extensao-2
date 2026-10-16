function Inventory () constructor{
	
	_items = array_create(2, undefined);
	selected_index = 0;
	
    item_add = function(_name, _quantity, _sprite) {
        for (var i = 0; i < array_length(_items); i++) {
            if (is_undefined(_items[i])) {
                _items[i] = {
                    name: _name,
                    quantity: _quantity,
                    sprite: _sprite
                };

                show_debug_message("Item " + _name +"no slot " + string(i+1));

                return true;
            }
        }

        show_debug_message("Inventário cheio");
        return false;
    };
	
	item_use = function() {
        if (is_undefined(_items[selected_index])) {
            show_debug_message("Slot selecionado está vazio");
            return;
        }
        
        show_debug_message("Usando " + _items[selected_index].name);
        Player.item_held = _items[selected_index].name
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