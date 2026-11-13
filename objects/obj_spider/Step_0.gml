// Congela inimigo caso necessário (ex: Pílula, troca de sala)
if (global.frozen) {
    image_speed = 0;                 // para a animação
    for (var i = 0; i < 7; i++) {    // pausa todos os alarms
        if (alarm[i] > 0) alarm[i] += 1;
    }
    exit;
}

image_speed = 1;

if (in_flashlight_cone)
{
    apply_flashlight_stun();
}
else if (CURRENT_STATE == SPIDER_STATES.STUNNED)
{
    STUN_TIMER -= 1;

    if (STUN_TIMER <= 0)
    {
        FLASHLIGHT_STUNNED = false;
        CURRENT_STATE = STATE_BEFORE_STUN;
        VEL =VEL_BEFORE_STUN  

        reset_alarms();
        reset_path();
        change_sprite();
    }
}

if (CURRENT_STATE == SPIDER_STATES.STUNNED)
{
    image_speed = 0;
	alarm[3] += 3;
    
    return;
}



rng = irandom(100);
state_behavior();
enemy_separation(16, 2, 4, true, obj_chaser);
enemy_separation(24, 2, 4,  true, obj_spider);
enemy_separation(16, 2, 4, true, Clown);

if (on_path){
	path_move();
}