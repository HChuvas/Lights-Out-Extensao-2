// Congela inimigo caso necessário (ex: Pílula, troca de sala)
if (global.frozen) {
    image_speed = 0;                 // para a animação
    for (var i = 0; i < 7; i++) {    // pausa todos os alarms
        if (alarm[i] > 0) alarm[i] += 1;
    }
    exit;
}

image_speed = VEL * VEL_MODIFIER;
rng = irandom(100);
state_behavior();
enemy_separation(16, 2, 4, true, obj_chaser);
enemy_separation(24, 2, 4,  true, obj_spider);
enemy_separation(16, 2, 4, true, Clown);

if (on_path){
	path_move();
}