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
enemy_separation();

if (on_path){
	path_move();
}