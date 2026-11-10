if (CURRENT_STATE != CHASER_STATES.REST and CURRENT_STATE != CHASER_STATES.ATTACK ){
	var _player_in_vision = self.perception();
	if ( _player_in_vision != noone ){
		if ( !_player_in_vision.imune ){
			player_last_place_seen = [_player_in_vision.x,  _player_in_vision.y];
			CURRENT_STATE = CHASER_STATES.CHASE;
		}
	}
}

alarm[7] = PERCEPTION_INTEVAL_TIME;