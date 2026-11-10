//web slow
FINAL_VEL = VEL * VEL_MODIFIER;


rng = irandom(100);
image_speed = FINAL_VEL;
state_behavior();
enemy_separation();

if (on_path){
	path_move();
}