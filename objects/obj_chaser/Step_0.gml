show_debug_message(CURRENT_STATE);
rng = irandom(100);
image_speed = VEL;

if (CURRENT_STATE != CHASER_STATES.REST and CURRENT_STATE != CHASER_STATES.ATTACK ){
	var _player_in_vision = self.perception();
	if ( _player_in_vision != noone ){
		player_last_place_seen = [_player_in_vision.x,  _player_in_vision.y];
		CURRENT_STATE = CHASER_STATES.CHASE;
	}
	
	if (on_path){
		path_move();
	}
}

state_behavior();
