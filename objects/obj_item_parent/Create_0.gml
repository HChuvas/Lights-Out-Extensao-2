event_inherited();
prompt = "Pick up";

interact = function() {
    if (!instance_exists(obj_inventory)) return;
    if (obj_inventory.inventory.item_add(_name, _quantity)) instance_destroy();
};
