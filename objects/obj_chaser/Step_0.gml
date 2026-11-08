rng = irandom(100);
image_speed = VEL;
state_behavior();
enemy_separation();

if (on_path){
	path_move();
}