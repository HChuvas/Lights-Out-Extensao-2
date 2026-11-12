event_inherited();
prompt = "Pick up";

// item largado pelo jogador já vem com este valor, itens normais da sala começam como não consumidos
if (!variable_instance_exists(id, "_consumed")) _consumed = false;
if (!variable_instance_exists(id, "_dropped")) _dropped = false; // true = largado pelo jogador

interact = function() {
    if (!instance_exists(obj_inventory)) return;
    if (obj_inventory.inventory.item_add(_name, _quantity, _consumed)) instance_destroy();
};
