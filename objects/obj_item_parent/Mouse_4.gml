var inv = instance_find(obj_inventory, 0);

if (inv != noone) {
    var added = inv.inventory.item_add(_name, _quantity);

    if (added) {
        instance_destroy();
    }
}