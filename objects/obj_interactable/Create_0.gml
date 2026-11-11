// Pai de tudo que dá pra interagir com F.
// Os filhos mudam "prompt" e "interact" no Create (depois de event_inherited()).
if (!variable_instance_exists(id, "prompt")) prompt = "Interact";
interact = function() {};
