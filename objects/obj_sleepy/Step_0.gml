x = owner.x + 6;
y = owner.y - 17;

if ( owner.CURRENT_STATE !=  CHASER_STATES.REST){
	instance_destroy();
}