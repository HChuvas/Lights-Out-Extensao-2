
image_speed = VEL;
rng = irandom(100);

state_behavior();
enemy_separation();
if (on_path){
	path_move();
}