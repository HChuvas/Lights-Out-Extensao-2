life_points = 3;
player_speed = 1
item_held = ""
facing = "down"
wall_map = layer_tilemap_get_id("Walls")
bottom_wall_map = layer_tilemap_get_id("BottomWalls")
camera = instance_create_layer(x, y, "Instances", obj_camera)
glow = instance_create_layer(x, y, "Instances", obj_player_natural_light);
light = instance_create_layer(x, y, "Instances", obj_light_cone);
light.on = false;
frozen = false;
fade = 0;
rem_x = 0;
rem_y = 0;
display_set_gui_size(1280, 720);

//param to aply a boder distance to push enemys away from player
w_separation_border = 7;
h_separation_border = 8;

//web params
VEL_MODIFIER = 1;
FINAL_VEL = 1;

//i frames params
tps = game_get_speed(gamespeed_fps);
hited = false;
imune = false
i_frames_times = 6;
i_frames_count = 0;
//i frames duraction timer 
alarm[0] = -1;

damage_taken = 0;

function aply_i_frames(){
	if (!hited){return}
	
	take_damage();
	hited = false;
	imune = true;
	audio_play_sound(choose(damage_sound1, damage_sound2, damage_sound3), 1, false);
	image_alpha = 0.5;

	alarm[0] = tps / 2.5;
}

function take_damage(){
	if (damage_taken > 0){
		life_points -= damage_taken;
		damage_taken = 0;
	}
}
