// Player é persistente e também está colocado nas rooms: se já existe um, este é cópia e some
if (instance_number(Player) > 1) {
    instance_destroy();
    exit;
}

life_points = 3;
player_speed = 1
item_held = ""
facing = "down"
wall_map = layer_tilemap_get_id("Walls")
bottom_wall_map = layer_tilemap_get_id("BottomWalls")
camera = instance_create_layer(x, y, "Instances", obj_camera)
glow = instance_create_layer(x, y, "Instances", obj_player_natural_light);
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
	if (pg_god()) { hited = false; return; } // debug: god mode
	
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

// interação (F)
interact_range = 16;
target = noone;

consume_frame = -1;

//efeito da meia: para deixar o moleque rápido
socks_speed_timer = 0;
socks_speed_multiplier = 1.75;

// portas
door_posts = [];
door_posts_key = "";
door_posts_timer = 0;

function rebuild_door_posts() {
    door_posts = [];
    var _maps = [];
    if (layer_exists("Tiles_1")) {
        var _m1 = layer_tilemap_get_id("Tiles_1");
        if (_m1 != -1) array_push(_maps, _m1);
    }
    if (variable_global_exists("pg_frames_map") && variable_global_exists("pg_front_room") && global.pg_front_room == room && global.pg_frames_map != -1) array_push(_maps, global.pg_frames_map);

    for (var _i = 0; _i < array_length(_maps); _i++) {
        var _m = _maps[_i];
        var _tw = tilemap_get_tile_width(_m), _th = tilemap_get_tile_height(_m);
        var _mx = tilemap_get_x(_m), _my = tilemap_get_y(_m);
        for (var _cx = 0; _cx < tilemap_get_width(_m); _cx++) {
            for (var _cy = 0; _cy < tilemap_get_height(_m); _cy++) {
                var _td = tilemap_get(_m, _cx, _cy);
                if (_td == -1) continue;
                var _idx = tile_get_index(_td);
                var _px = _mx + _cx * _tw, _py = _my + _cy * _th;
                if (_idx == 112 || _idx == 134) array_push(door_posts, { x1: _px, x2: _px + 5, y1: _py, y2: _py + _th });
                else if (_idx == 113 || _idx == 135) array_push(door_posts, { x1: _px + 14, x2: _px + 16, y1: _py, y2: _py + _th });
            }
        }
    }
}
