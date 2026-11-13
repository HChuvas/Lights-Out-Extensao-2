event_inherited();
prompt = "Pegar o lanche";
glow_t = random(360);

// Pegar o lanche apaga as luzes e acorda os monstros
interact = function() {
    pg_pickup_snack();
    instance_destroy();
};
