x = owner.x + 6;
y = owner.y - 17;
image_alpha = owner.image_alpha;   // some junto com o inimigo (Pílula)

if ( owner.CURRENT_STATE !=  CHASER_STATES.REST){
	instance_destroy();
}