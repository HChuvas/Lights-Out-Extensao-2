var inv = instance_find(obj_inventory, 0);

if (inv != noone) {
    var added = inv.inventory.item_add(
        "flashlight",
        1,
        spr_flashlight_in
    );

    if (added) {
        instance_destroy();
    }
}