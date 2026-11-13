var inv = instance_find(obj_inventory, 0);

if (inv != noone) {
    var added = inv.inventory.item_add(
        "water_cup",
        1,
        spr_water_cup
    );

    if (added) {
        instance_destroy();
    }
}