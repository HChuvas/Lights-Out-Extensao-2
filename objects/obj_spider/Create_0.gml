event_inherited();

// mask
mask_index = spr_normal_chaser;

//vision params
VISION_RANGE = 175;
SHOOT_RANGE = 125;
SHOOT_ANGLE = [-10 ,0, 10]

//movement params
VEL = 1.2;
direction = 0;

//states params
enum SPIDER_STATES {
	WATCH, 
	PATROL,
	TRAVEL,
	CHASE,
	SHOOT,
	STOP,
	STUNNED
}
CURRENT_STATE = SPIDER_STATES.TRAVEL;

//time params
PERCEPTION_INTEVAL_TIME = 2;		//time inteval to do a perception / avoid calling the perception funtion each step
ATTACK_DELAY_TIME = 0.2;		//DUH  / avoid apam attacks
ATTACK_DURATION_TIME = 30;
MAX_ACTION_TIME_LEN = 10;
SPRITE_CHANGE_INTEVAL = 4;
WATCH_TIME_RANGE = [2, 4];

//attack params
ATTACK_DAMAGE = 1;
ATTACK_LIFETIME = 10;
ATTACKING  = false;
ATTACK_VEL = 1.6;
STOP_AFTER_ATTACK = 0.75;

//alarm for max action len // avoid infinite action time
alarm[0] = -1;
//alarm for sprite change
alarm[1] = SPRITE_CHANGE_INTEVAL;
//alarm for WATCH time duration;
alarm[2] = -1;
last_sprite = spr_spider_idle_down;
//alarm to do a perception check
alarm[3] = PERCEPTION_INTEVAL_TIME;
//alarm to avoid create a new path every step during a chase
alarm[4] = -1;
//alarm to do the attack
alarm[5] = -1
//alarm to wait after an attack
alarm[6] = -1;

//path var
my_path = path_add();
on_path = false;
path_point_index = noone;
path_number_points = noone;
stuck_t = 0;

//POV last place player seen
player_last_place_seen = [noone, noone];

//web params
actual_web_id = noone;
web_counter = 0;
web_patrol_range = 100;

//latern
STUN_DURATION = 3 * game_get_speed(gamespeed_fps);
STUN_TIMER = 0;

STATE_BEFORE_STUN = SPIDER_STATES.WATCH;
VEL_BEFORE_STUN = VEL;

FLASHLIGHT_STUNNED = false;

//RNG var
PATROL_TO_TRAVEL_CHANCE = 20;
randomise();
rng = irandom(100);

//logic of each state
function state_behavior(){
	var _pos;
	
	switch(CURRENT_STATE){
		
		case(SPIDER_STATES.WATCH):
			if ( alarm[2] == -1 ){
				alarm[2] = random_range(fps * WATCH_TIME_RANGE[0], fps * WATCH_TIME_RANGE[1]);
			}
			return;
		
		case(SPIDER_STATES.PATROL):
			if (!on_path){
				_pos = get_unocupied_position_in_web_range();
				if (!create_path(_pos[0],_pos[1])) { state_change(); }
			}
			return;
			
		case(SPIDER_STATES.TRAVEL):
			if (!on_path){
				_pos = get_next_web_position();
				if (!create_path(_pos[0],_pos[1])) { state_change(); }
			}
			return;
			
		case(SPIDER_STATES.CHASE):
			//verify player new position if in line of sight
			if (alarm[4] == -1){
				alarm[4] = PERCEPTION_INTEVAL_TIME;
				on_path = false;
				if (!create_path(player_last_place_seen[0], player_last_place_seen[1])) { state_change(true); }
			}
			//verify if player in attack range
			var _player_in_shoot_distance = self.perception(SHOOT_RANGE, SHOOT_ANGLE );
			if (_player_in_shoot_distance != noone){
				reset_alarms();
				CURRENT_STATE = SPIDER_STATES.SHOOT;
			}
			return;
			
		case(SPIDER_STATES.SHOOT):
				if (alarm[5] == -1){
					alarm[5] = ATTACK_DELAY_TIME*fps;
				}
				return;
		case(SPIDER_STATES.STOP):
			if (alarm[6] == -1){
				alarm[6] = STOP_AFTER_ATTACK * fps;
			}
	}
}

//get next web to spider go
function get_next_web_position(){
	var _n = instance_number(obj_spider_web);
	if (_n == 0){ return [x, y]; }

	if (_n > 1){
		var _tries = 0;
		do {
			web_counter = irandom_range(0, _n - 1);
			_tries++;
		} until (web_counter != actual_web_id || _tries > 20);
	} else {
		web_counter = 0;
	}

	var _web = instance_find(obj_spider_web, web_counter);
	return [_web.x, _web.y];
}

function get_farthest_web_position(){
    var _max_web_count = instance_number(obj_spider_web);

    var _best_web = noone;
    var _max_distance = -1;
	var _indice_web = noone;

    for (var i = 0; i < _max_web_count; i++){
        var _web = instance_find(obj_spider_web, i);

        var _dist = point_distance(
            _web.x, _web.y,
            Player.x, Player.y
        );

        if (_dist > _max_distance){
            _max_distance = _dist;
            _best_web = _web;
			_indice_web = i;
        }
    }
	
	actual_web_id = _indice_web;
    if (_best_web != noone){
        return [_best_web.x, _best_web.y];
    }

    return [x, y];
	}

function get_unocupied_position_in_web_range(){
	var _n = instance_number(obj_spider_web);
	if (_n == 0){ return [x, y]; }
	var _web = instance_find(obj_spider_web, min(web_counter, _n - 1));
	var _cs = obj_manager.cell_size;

	for (var _i = 0; _i < 30; _i++) {
		var _x = irandom_range(_web.x - web_patrol_range, _web.x + web_patrol_range);
		var _y = irandom_range(_web.y - web_patrol_range, _web.y + web_patrol_range);
		var _cx = floor(_x / _cs);
		var _cy = floor(_y / _cs);

		if (mp_cell_free(obj_manager.map_grid, _cx, _cy)) {
			return [_cx * _cs + _cs / 2, _cy * _cs + _cs / 2];
		}
	}
	return [_web.x, _web.y];
}

//get all objects in line of sight
function raycasting_pov(vision_range = VISION_RANGE, ang = noone) {
	var collision_tilemap = layer_tilemap_get_id(layer_get_id("Collision"));
	
	var _dir = direction_cardinal();
    var objs_in_vision = [ ];
	var angles = [];
	
	if (ang != noone) {
		angles = ang 
		for (var i = 0; i < array_length(ang); i++) {
		    angles[i] = _dir; 
		}
	} else {
        for (var i = 0; i < 360; i += 3) {
            array_push(angles, i);
        }
    }

    for (var i = 0; i < array_length(angles); i++) {
		var _ang = angles[i];

        var x2 = self.x + lengthdir_x(vision_range, _ang);
        var y2 = self.y + lengthdir_y(vision_range, _ang);
		
		var hit = collision_line(self.x, self.y, x2, y2, Player, false, true);

		if (hit != noone) {
		    var wall = collision_line(
		        self.x, self.y,
		        hit.x, hit.y,
		        collision_tilemap,
		        false, true
		    );

			    if (wall == noone) {
			        array_push(objs_in_vision, hit);
			    }
			}
	}

    return array_unique(objs_in_vision);
}


//return only the player in line of sight
function perception(vision_range = VISION_RANGE, ang = noone){
	var _objs_in_vision  = self.raycasting_pov(vision_range, ang); 
	var _player_in_vision = noone;
	
	for (var i = 0; i < array_length(_objs_in_vision); i++ ){
		if ( _objs_in_vision[i].object_index  == Player ){
			_player_in_vision = _objs_in_vision[i];
			break;
		}
	}
	return _player_in_vision;
}



function create_path(target_x = noone, target_y = noone){
	var _g = obj_manager.map_grid;
	var _t = mp_snap_to_free(_g, target_x, target_y, 4);
	var _s = mp_snap_to_free(_g, self.x, self.y, 2);
	if (_t != undefined && _s != undefined && mp_grid_path(_g, my_path, _s[0], _s[1], _t[0], _t[1], true)){
		on_path = true;
		path_point_index = 1;
		path_number_points = path_get_number(my_path);
		stuck_t = 0;
		return true;
	}
	return false;
}

//manual movement logic
function path_move(){
	//not on a path
	if (!on_path){ return; }
	
	//reached end of the path
	if (path_point_index >= path_number_points){
		reset_path();
		//reset states 
		state_change(true);
		return;
	}
	
	var _x = path_get_point_x(my_path, path_point_index);
	var _y = path_get_point_y(my_path, path_point_index);
	var _vel = VEL * VEL_MODIFIER;   // slow da cola
	var _dist = point_distance(x, y, _x, _y);
	
	//reached point go to the next
	if (_dist <= max(_vel, 1) + 1){
		path_point_index += 1;
		return;
	}
	
	var _dir = point_direction(self.x, self.y, _x, _y);
	direction = _dir;
	var _dx = lengthdir_x(_vel, _dir);
	var _dy = lengthdir_y(_vel, _dir);
	var _px = x, _py = y;
	
	var collision_tilemap = layer_tilemap_get_id(layer_get_id("Collision"));
	//dont colide with obstacles
	if (!place_meeting(x + _dx, y, [collision_tilemap])) { x += _dx; }  
	if (!place_meeting(x, y + _dy, [collision_tilemap])) { y += _dy; } 
	
	// redo when stuck
	if (point_distance(_px, _py, x, y) < 0.1) { stuck_t++; } else { stuck_t = 0; }
	if (stuck_t > 15){
		stuck_t = 0;
		reset_path();
		if (CURRENT_STATE == SPIDER_STATES.CHASE){ alarm[4] = 1; }
	}
}


can_hear_alert = function() {
    return CURRENT_STATE == SPIDER_STATES.PATROL
        || CURRENT_STATE == SPIDER_STATES.TRAVEL
		|| CURRENT_STATE == SPIDER_STATES.WATCH;
}

hear_alert = function(_x, _y) {
    if (!can_hear_alert()) return false;

    reset_path();

    VEL = 1;
    player_last_place_seen = [_x, _y];
    CURRENT_STATE = SPIDER_STATES.CHASE;
    return true;
}

// :P
function change_sprite() {

    var _dir;
	var _new_sprite;
    if (direction > 315 or direction <= 45) {  _dir = "right"; }
    else if (direction <= 135) { _dir = "up"; }
    else if (direction <= 225) { _dir = "left"; }
    else {  _dir = "down"; }

    switch (CURRENT_STATE) {
        case SPIDER_STATES.SHOOT:
            switch (_dir) {
                case "right": _new_sprite = spr_spider_attack_right; break;
                case "up":    _new_sprite = spr_spider_attack_up;    break;
                case "left":  _new_sprite = spr_spider_attack_left;  break;
                case "down":  _new_sprite = spr_spider_attack_down;  break;
            }
            break;

        case SPIDER_STATES.PATROL:
            switch (_dir) {
                case "right": _new_sprite = spr_spider_walk_right; break;
                case "up":    _new_sprite = spr_spider_walk_up;    break;
                case "left":  _new_sprite = spr_spider_walk_left;  break;
                case "down":  _new_sprite = spr_spider_walk_down;  break;
            }
            break;
		
		case SPIDER_STATES.TRAVEL:
            switch (_dir) {
                case "right": _new_sprite = spr_spider_walk_right; break;
                case "up":    _new_sprite = spr_spider_walk_up;    break;
                case "left":  _new_sprite = spr_spider_walk_left;  break;
                case "down":  _new_sprite = spr_spider_walk_down;  break;
            }
            break;
		    
			case SPIDER_STATES.CHASE:
	            switch (_dir) {
	                case "right": _new_sprite = spr_spider_walk_right; break;
	                case "up":    _new_sprite = spr_spider_walk_up;    break;
	                case "left":  _new_sprite = spr_spider_walk_left;  break;
	                case "down":  _new_sprite = spr_spider_walk_down;  break;
	            }
				break;

        default: 
            switch (_dir) {
                case "right": _new_sprite = spr_spider_idle_right; break;
                case "up":    _new_sprite = spr_spider_idle_up;    break;
                case "left":  _new_sprite = spr_spider_idle_left;  break;
                case "down":  _new_sprite = spr_spider_idle_down;  break;
            }
            break;
    }
	
	if ( _new_sprite != last_sprite ){
		sprite_index = _new_sprite;
		last_sprite = _new_sprite;
	}
}
	
function state_change(end_of_a_path = false){
	reset_alarms();
	
	alarm[0] = MAX_ACTION_TIME_LEN * fps;
	switch(CURRENT_STATE){
		case(SPIDER_STATES.WATCH): 
			if (rng <= PATROL_TO_TRAVEL_CHANCE){
				CURRENT_STATE = SPIDER_STATES.TRAVEL;
			} else {
				CURRENT_STATE = SPIDER_STATES.PATROL;
			}
			return;
			
		case(SPIDER_STATES.PATROL):  CURRENT_STATE = SPIDER_STATES.WATCH; return;
		case(SPIDER_STATES.TRAVEL): CURRENT_STATE = SPIDER_STATES.PATROL; return;
		case(SPIDER_STATES.CHASE):  if (end_of_a_path){ CURRENT_STATE = SPIDER_STATES.WATCH;} else {CURRENT_STATE = SPIDER_STATES.CHASE;} return;
		case(SPIDER_STATES.SHOOT):  CURRENT_STATE = SPIDER_STATES.STOP; return;
		case(SPIDER_STATES.STOP):	CURRENT_STATE = SPIDER_STATES.WATCH; return;
	}
}

function reset_alarms() {
	alarm[0] = -1;
	alarm[2] = -1;
	alarm[4] = -1;
	alarm[5] = -1;
	alarm[6] = -1;

}

function direction_cardinal(_dir = direction) {
    _dir = ((_dir mod 360) + 360) mod 360; 

    if (_dir > 315 or _dir <= 45) return 0;
    if (_dir <= 135) return 90;
    if (_dir <= 225) return 180;
    return 270;
}

function reset_path(){
		on_path = false;
		path_point_index = noone;
		path_number_points = noone;

}

function apply_flashlight_stun()
{
    if (CURRENT_STATE != SPIDER_STATES.STUNNED)
    {
        STATE_BEFORE_STUN = CURRENT_STATE;

        // Não retoma um ataque interrompido pela lanterna
        if (STATE_BEFORE_STUN == SPIDER_STATES.SHOOT)
        {
            STATE_BEFORE_STUN = SPIDER_STATES.WATCH;
        }

        VEL_BEFORE_STUN = VEL;
        CURRENT_STATE = SPIDER_STATES.STUNNED;

        reset_alarms();
        reset_path();

        ATTACKING = false;

        change_sprite();
    }

    STUN_TIMER = STUN_DURATION;
    FLASHLIGHT_STUNNED = true;
    VEL = 0;
    image_speed = 0;
	in_flashlight_cone = false;
}