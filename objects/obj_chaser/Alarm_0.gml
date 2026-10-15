//rng chnace to go to patrol
if(rng <= WATCH_TO_PATROL_RNG){
	CURRENT_STATE = "patrol";
}

else{
	CURRENT_STATE = "watch";
}