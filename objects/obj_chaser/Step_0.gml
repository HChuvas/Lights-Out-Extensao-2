// Congela iminigo caso necessário (ex: Pílula, troca de sala)
if (global.frozen) {
    image_speed = 0;                 // para a animação
    for (var i = 0; i < 8; i++) {    // pausa todos os alarms
        if (alarm[i] > 0) alarm[i] += 1;
    }
    exit;
}

//web slow
FINAL_VEL = VEL * VEL_MODIFIER;

rng = irandom(100);
image_speed = FINAL_VEL;
state_behavior();
enemy_separation(5, 2, 4, true, obj_chaser);
enemy_separation(12, 2, 4, true, obj_spider);
enemy_separation(16, 2, 4, true, Clown);

if (on_path){
	path_move();
}