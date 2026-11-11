image_speed = 1;
rng = irandom(100);
state_behavior();
enemy_separation();

if (on_path){
	path_move();
}