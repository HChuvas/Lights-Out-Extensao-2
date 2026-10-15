//atack if not resting
if ( CURRENT_STATE != "rest" ) {
	//reset path and vel aceleration
	on_path = false;
	path_point_index = noone;
	path_number_points = noone;
	player_last_place_seen = [noone, noone];
	VEL = 1;

	//reset chase alarms
	alarm[2] = -1;
	alarm[3] = -1;

	//kill child :P
	CURRENT_STATE = "attack";

}
