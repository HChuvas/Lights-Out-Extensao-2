if (CURRENT_STATE != SPIDER_STATES.STOP and CURRENT_STATE != SPIDER_STATES.SHOOT ){
	var _player_in_vision = self.perception();
	var _player_in_shoot_vision = self.perception(SHOOT_RANGE, SHOOT_ANGLE);
	
	if ( _player_in_shoot_vision != noone ){
		if ( !_player_in_shoot_vision.imune ){
			reset_path()
			reset_alarms();
			CURRENT_STATE = SPIDER_STATES.SHOOT;
		}
	} else {
		if ( _player_in_vision != noone ){
			if ( !_player_in_vision.imune ){
				player_last_place_seen = [_player_in_vision.x,  _player_in_vision.y];
				reset_alarms();
				CURRENT_STATE = SPIDER_STATES.CHASE;
			}
		}
	}
}

alarm[3] = PERCEPTION_INTEVAL_TIME;