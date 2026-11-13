// Congela iminigo caso necessário (ex: Pílula, troca de sala)
if (global.frozen) {
    image_speed = 0; // para a animação
    for (var i = 0; i < 8; i++) { // pausa todos os alarms
        if (alarm[i] > 0) alarm[i] += 1;
    }
    exit;
}

//web slow
FINAL_VEL = VEL * VEL_MODIFIER;

image_speed = 1;

rng = irandom(100);

if (in_flashlight_cone)
{
    apply_flashlight_stun();
}
else if (CURRENT_STATE == CHASER_STATES.STUNNED)
{
    STUN_TIMER -= 1;

    if (STUN_TIMER <= 0)
    {
        FLASHLIGHT_STUNNED = false;
        CURRENT_STATE = STATE_BEFORE_STUN;
        VEL = max(VEL_BEFORE_STUN, 1); //never come back from a stun with VEL 0

        for (var i = 0; i <= 5; i++) alarm[i] = -1;

        on_path = false;
        path_point_index = noone;
        path_number_points = noone;

        change_sprite();
    }
}

if (CURRENT_STATE == CHASER_STATES.STUNNED)
{
    image_speed = 0;
    return;
}

state_behavior();
enemy_separation(5, 2, 4, true, obj_chaser);
enemy_separation(12, 2, 4, true, obj_spider);
enemy_separation(16, 2, 4, true, Clown);

if (on_path){
	path_move();
}