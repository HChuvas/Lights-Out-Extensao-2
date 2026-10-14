//vision params
IDLE_VISION_RANGE = 100;
CHASE_VISION_RANGE = [80, 125];

//movement params
VEL = 1.0;
ACE = 0.2;

//stamina param
STAMINA = 2.0;
MAX_STAMINA = 2.0;
REST_REGEN = 0.5;

//"watch", "patrol", "chase", "attack", "rest"
CURRENT_STATE = "watch";
WATCH_TO_PATROL_RNG = 75;		//chance% to patrol after a watch time
WATCH_TIME_RANGE = [4, 8];		//set watch time: range 4s - 8s
MAX_PATROL_TIME_DURATION = 10;		//max time doing a patrol / avoid patrol to too long
PERCEPTION_INTEVAL_TIME = 0.25;		//time inteval to do a perception / avoid calling the perception funtion each step
REST_INTEVAL_TIME = 0.5;		//time inteval to rest_regen stamina / avoid regen stamina per step
ATTACK_DELAY_TIME = 0.2;        //Duh

//alarm for watch state
alarm[0] = -1;
//alarm for patrol state
alarm[1] = -1;
//alarm to avoid creating a new path every step during a chase
alarm[2] = -1;
//alarm to to aply the aceleration during a chase
alarm[3] = -1;
//alarm to attack state
alarm[4] = -1;
//alarm to rest state
alarm[5] = -1;

//path var
my_path = path_add();
on_path = false;
path_point_index = noone;
path_number_points = noone;

//POV last place player seen
player_last_place_seen = [noone, noone];

//RNG var
randomise();
rng = irandom(100);

//logic of each state
function state_behavior(){
	
	switch(CURRENT_STATE){
		
		//stay still and watch arround
		case("watch"):
			if(alarm[0] == -1){
				alarm[0] = random_range(fps * WATCH_TIME_RANGE[0], fps * WATCH_TIME_RANGE[1]);
			}
			return;
			
		//walk to a random point
		case("patrol"):
			if(alarm[1] == -1){
				alarm[1] = fps * MAX_PATROL_TIME_DURATION;
				var _random_point = get_random_unocupied_grid_cell(obj_manager.map_grid);
				path_move(_random_point[0], _random_point[1]);
			}
			return;
		
		//chase player, ramp-up velocity vroooom
		case("chase"):
			if (alarm[2] = -1){
						alarm[2] = fps * PERCEPTION_INTEVAL_TIME;
						on_path = false;
						path_move(player_last_place_seen[0], player_last_place_seen[1]);
			}
			if (alarm[3] = -1){
				alarm[3] = 2*fps;
			}
			return;
			
			//attack and exhaust stamina (avoid attack spam)
			case("attack"):
				if (alarm[4] == -1){
					STAMINA = 0;
					alarm[4] = ATTACK_DELAY_TIME*fps;
				}
				return;
			
			//rest until stamina recovered :p
			case("rest"):
				if (alarm[5] == -1) {
					alarm[5] = REST_INTEVAL_TIME*fps;
				}
				return;
	}
}

//get all objects in line of sight
function raycasting_pov(vision_range = IDLE_VISION_RANGE){
	var objs_in_vision = [];
	
	if (CURRENT_STATE == "watch") {
	
	}
	for( var ang = 0; ang < 360; ang = ang + 9){
			var x2 = lengthdir_x(vision_range, ang);
			var y2 = lengthdir_y(vision_range, ang);
			
			x2 = self.x + x2;
			y2 = self.y + y2;
			
			var hit = collision_line(self.x, self.y, x2, y2, obj_obstacle, false, true);
			
			if (hit == noone ){
				hit = collision_line(self.x, self.y, x2, y2, Player, false, true);
			}
			
			if ( hit == noone ){
				hit = collision_line(self.x, self.y, x2, y2, obj_npc, false, true);
			}
			
			if ( hit != noone ){
				array_push(objs_in_vision, hit);
			}
	}
	
	objs_in_vision = array_unique(objs_in_vision);
	return objs_in_vision;
}

//return only the player in line of sight
function perception(){
	var _objs_in_vision = self.raycasting_pov();
	var _player_in_vision = noone;
	
	for (var i = 0; i < array_length(_objs_in_vision); i++ ){
		if ( _objs_in_vision[i].object_index  == Player ){
			_player_in_vision = _objs_in_vision[i];
			break;
		}
	}
	return _player_in_vision;
}

//manual movement logic
function path_move(target_x = noone, target_y = noone){
	if (!on_path){
		if(mp_grid_path(obj_manager.map_grid, my_path, self.x, self.y, target_x, target_y,  true) ){ 
					on_path = true;
					path_point_index = 0;
					path_number_points = path_get_number(my_path);
		} else {
			if (CURRENT_STATE = "patrol") {
				alarm[1] = 1;
			} else if (CURRENT_STATE = "chase"){
				stamina = 0;
				alarm[2] = 1;
				alarm[3] = 1;
			}
		}
	}
	
	if (path_point_index == path_number_points){
		on_path = false;
		path_point_index = noone;
		path_number_points = noone;
		
		if (CURRENT_STATE = "patrol") {
			alarm[1] = 1;
		} else if (CURRENT_STATE = "chase"){
			stamina = 0;
			alarm[2] = 1;
			alarm[3] = 1;
		}
	}
	
	var _x = path_get_point_x(my_path, path_point_index);
	var _y = path_get_point_y(my_path, path_point_index);
	
	var dist = point_distance(self.x, self.y, _x, _y);
	
	if (dist <= self.VEL){
		path_point_index += 1;
	} else {
		var dir = point_direction(self.x, self.y, _x, _y);
	
        var dx = lengthdir_x(VEL, dir);
        var dy = lengthdir_y(VEL, dir);

        if (!place_meeting(x + dx, y, obj_obstacle)) {
            self.x += dx;
        }

        if (!place_meeting(x, y + dy, obj_obstacle)) {
            self.y += dy;
		}
	}
}