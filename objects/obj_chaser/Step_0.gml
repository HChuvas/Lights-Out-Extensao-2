rng = irandom(100);
image_speed = VEL;

if (CURRENT_STATE != CHASER_STATES.REST and CURRENT_STATE != CHASER_STATES.ATTACK ){
	var _player_in_vision = self.perception();
	if ( _player_in_vision != noone ){
		if ( !_player_in_vision.imune ){
			player_last_place_seen = [_player_in_vision.x,  _player_in_vision.y];
			CURRENT_STATE = CHASER_STATES.CHASE;
		}
	}
	
	if (on_path){
		path_move();
	}
}

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
        VEL = VEL_BEFORE_STUN;

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
enemy_separation();