//if tired, stop chase and rest
if (STAMINA <= 0){
	VEL = 1;
	CURRENT_STATE = "rest";
	on_path = false;
	path_point_index = noone;
	path_number_points = noone;
} else {
	//else aply aceleration
	STAMINA = STAMINA - 0.2;
	VEL = VEL + ACE;
}