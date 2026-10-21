event_inherited();

//vision params
IDLE_VISION_RANGE = 50;
CHASE_VISION_RANGE = [80, 125];

//movement params
VEL = 1.0;
ACE = 0.15;
direction = 0;

//stamina param
STAMINA = 1.0;
MAX_STAMINA = 1.0;
REST_REGEN = 0.5;

//states params
enum CHASER_STATES {
	WATCH,
	PATROL,
	CHASE,
	ATTACK,
	REST
}
CURRENT_STATE = CHASER_STATES.WATCH;

//time params
WATCH_TO_PATROL_RNG = 75;		//chance% to patrol after a watch time
WATCH_TIME_RANGE = [4, 8];		//set watch time: range 4s - 8s
MAX_PATROL_TIME_DURATION = 2;		//max time doing a patrol / avoid patrol to too long
PERCEPTION_INTEVAL_TIME = 0.5;		//time inteval to do a perception / avoid calling the perception funtion each step
REST_INTEVAL_TIME = 0.5;		//time inteval to rest_regen stamina / avoid regen stamina per step
ATTACK_DELAY_TIME = 0.2;		//DUH  / avoid apam attacks
ATTACK_DURATION_TIME = 0.65  //time to use the sprite animation 

//attack params
ATTACK_DAMAGE = 1;
ATTACK_LIFETIME = 0.5;
ATTACKING  = false;

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
//alarm to sprint change
alarm[6] = 3;

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
		case(CHASER_STATES.WATCH):
			if(alarm[0] == -1){
				alarm[0] = random_range(fps * WATCH_TIME_RANGE[0], fps * WATCH_TIME_RANGE[1]);
			}
			return;
			
		//walk to a random point
		case(CHASER_STATES.PATROL):
			if(alarm[1] == -1){
				alarm[1] = fps * MAX_PATROL_TIME_DURATION;
				var _random_point = get_random_unocupied_grid_cell(obj_manager.map_grid);
				path_move(_random_point[0], _random_point[1]);
			}
			return;
		
		//chase player, ramp-up velocity vroooom
		case(CHASER_STATES.CHASE):
			//verify player new position if in line of sight
			if (alarm[2] == -1){
						alarm[2] = fps * PERCEPTION_INTEVAL_TIME;
						on_path = false;
						path_move(player_last_place_seen[0], player_last_place_seen[1]);
			}
			//aply aceleration 
			if (alarm[3] == -1){
				alarm[3] = 2*fps;
			}
			return;
			
			//attack and exhaust stamina (avoid attack spam)
			case(CHASER_STATES.ATTACK):
				if (alarm[4] == -1){
					VEL= 1;
					image_speed = VEL;
					STAMINA = 0;
					alarm[4] = ATTACK_DELAY_TIME*fps;
				}
				return;
			
			//rest until stamina recovered :p
			case(CHASER_STATES.REST):
				if (alarm[5] == -1) {
					alarm[5] = REST_INTEVAL_TIME*fps;
				}
				return;
	}
}

//get all objects in line of sight
function raycasting_pov(vision_range = IDLE_VISION_RANGE){
	var objs_in_vision = [];
	
	if (CURRENT_STATE ==CHASER_STATES.WATCH) {
	
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
				hit = collision_line(self.x, self.y, x2, y2, enemy_parent, false, true);
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
	//not on a path, create a new path
	if (!on_path){
		if(mp_grid_path(obj_manager.map_grid, my_path, self.x, self.y, target_x, target_y,  true) ){ 
					on_path = true;
					path_point_index = 0;
					path_number_points = path_get_number(my_path);
		} else {
			//if path not created sucefuly, reset state
			if (CURRENT_STATE == CHASER_STATES.PATROL) {
				alarm[1] = 1;
			} else if (CURRENT_STATE == CHASER_STATES.CHASE){
				stamina = 0;
				alarm[2] = 1;
				alarm[3] = 1;
			}
			return;
		}
	}
	
	//reached end of the path
	if (path_point_index == path_number_points){
		on_path = false;
		path_point_index = noone;
		path_number_points = noone;
		
			//reset states 
			if (CURRENT_STATE == CHASER_STATES.PATROL) {
				alarm[1] = 1;
			} else if (CURRENT_STATE == CHASER_STATES.CHASE){
				stamina = 0;
				alarm[2] = 1;
				alarm[3] = 1;
			}
			return;
	}
	
	var _x = path_get_point_x(my_path, path_point_index);
	var _y = path_get_point_y(my_path, path_point_index);
	
	var _dist = point_distance(x, y, _x, _y);
	
	//reched point go to the next
	if (_dist <= VEL){
		path_point_index += 1;
		
	} else {
		//if not, continue 
		var _dir = point_direction(self.x, self.y, _x, _y);
		direction = _dir;
		
        var _dx = lengthdir_x(VEL, _dir);
        var _dy = lengthdir_y(VEL, _dir);
		
		//dont colide with obstacles
        if (!place_meeting(x + _dx, y, [obj_obstacle, enemy_parent])) { x += _dx; }  
		if (!place_meeting(x, y + _dy, [obj_obstacle, enemy_parent])) { y += _dy; } 
	}
}

// funções do alerta

can_hear_alert = function() {
    return CURRENT_STATE == CHASER_STATES.WATCH
        || CURRENT_STATE == CHASER_STATES.PATROL;
}

hear_alert = function(_x, _y) {
    if (!can_hear_alert()) return false;

    alarm[0] = -1;
    alarm[1] = -1;
    alarm[2] = -1;

    on_path = false;
    path_point_index = noone;
    path_number_points = noone;

    VEL = 1;
    player_last_place_seen = [_x, _y];
    CURRENT_STATE = CHASER_STATES.CHASE;
    return true;
}

// :P
function change_sprite() {

    var _dir;

    if (direction > 315 or direction <= 45) {  _dir = "right"; }
    else if (direction <= 135) { _dir = "up"; }
    else if (direction <= 225) { _dir = "left"; }
    else {  _dir = "down"; }

    switch (CURRENT_STATE) {
        case CHASER_STATES.ATTACK:
            switch (_dir) {
                case "right": sprite_index = spr_evil_kid_attack_right; break;
                case "up":    sprite_index = spr_evil_kid_attack_up;    break;
                case "left":  sprite_index = spr_evil_kid_attack_left;  break;
                case "down":  sprite_index = spr_evil_kid_attack_down;  break;
            }
            break;

        case CHASER_STATES.REST:
            switch (_dir) {
                case "right": sprite_index = spr_evil_kid_idle_right; break;
                case "up":    sprite_index = spr_evil_kid_idle_up;    break;
                case "left":  sprite_index = spr_evil_kid_idle_left;  break;
                case "down":  sprite_index = spr_evil_kid_idle_down;  break;
            }
            break;

        case CHASER_STATES.WATCH:
            switch (_dir) {
                case "right": sprite_index = spr_evil_kid_idle_right; break;
                case "up":    sprite_index = spr_evil_kid_idle_up;    break;
                case "left":  sprite_index = spr_evil_kid_idle_left;  break;
                case "down":  sprite_index = spr_evil_kid_idle_down;  break;
            }
            break;

        default: 
            switch (_dir) {
                case "right": sprite_index = spr_evil_kid_walk_right; break;
                case "up":    sprite_index = spr_evil_kid_walk_up;    break;
                case "left":  sprite_index = spr_evil_kid_walk_left;  break;
                case "down":  sprite_index = spr_evil_kid_walk_down;  break;
            }
            break;
    }
}