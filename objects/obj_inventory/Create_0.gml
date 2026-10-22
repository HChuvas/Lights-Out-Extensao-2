if (instance_number(obj_inventory) > 1) {
    instance_destroy();
    exit;
}

inventory = new Inventory();