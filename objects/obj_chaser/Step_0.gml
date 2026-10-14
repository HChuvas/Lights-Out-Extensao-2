show_debug_message(CURRENT_STATE);
rng = irandom(100);

if (CURRENT_STATE != "rest" and CURRENT_STATE != "attack" ){
	var _player_in_vision = self.perception();
	if ( _player_in_vision != noone ){
		player_last_place_seen = [_player_in_vision.x,  _player_in_vision.y];
		CURRENT_STATE = "chase";
	}
	
	if (on_path){
		path_move();
	}
}

state_behavior();
