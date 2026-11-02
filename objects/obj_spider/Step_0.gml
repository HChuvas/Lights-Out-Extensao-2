rng = irandom(100);
image_speed = VEL;

if (CURRENT_STATE != SPIDER_STATES.RUN and CURRENT_STATE != SPIDER_STATES.SHOOT ){
	var _player_in_vision = self.perception();
	if ( _player_in_vision != noone ){
		if ( !_player_in_vision.imune ){
			player_last_place_seen = [_player_in_vision.x,  _player_in_vision.y];
			CURRENT_STATE = SPIDER_STATES.CHASE;
		}
	}
	
	if (on_path){
		path_move();
	}
}

state_behavior();
enemy_separation();