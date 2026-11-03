event_inherited();

//vision params
VISION_RANGE = 125;
SHOOT_RANGE = 50;

//movement params
VEL = 1.5;
direction = 0;

//states params
enum SPIDER_STATES {
	WATCH, 
	PATROL,
	TRAVEL,
	CHASE,
	SHOOT,
	RUN
}
CURRENT_STATE = SPIDER_STATES.TRAVEL;

//time params
PERCEPTION_INTEVAL_TIME = 1;		//time inteval to do a perception / avoid calling the perception funtion each step
ATTACK_DELAY_TIME = 0.2;		//DUH  / avoid apam attacks
WATCH_TIME = 2;
MAX_ACTION_TIME_LEN = 10;
SPRITE_CHANGE_INTEVAL = 2;
WATCH_TIME_RANGE = [2, 4];

//attack params
ATTACK_DAMAGE = 1;
ATTACK_LIFETIME = 0.5;
ATTACKING  = false;

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

//path var
my_path = path_add();
on_path = false;
path_point_index = noone;
path_number_points = noone;

//POV last place player seen
player_last_place_seen = [noone, noone];

//web params
actual_web_id = noone;
web_counter = 0;
web_patrol_range = 100;

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
				create_path(_pos[0],_pos[1]);
			}
			return;
			
		case(SPIDER_STATES.TRAVEL):
			if (!on_path){
				_pos = get_next_web_position();
				create_path(_pos[0],_pos[1]);
			}
			return;
			
		case(SPIDER_STATES.CHASE):
			/*var _player_in_shoot_distance = self.perception(SHOOT_RANGE);
			if (_player_in_shoot_distance != noone){
				CURRENT_STATE = SPIDER_STATES.SHOOT;
			}*/
			//verify player new position if in line of sight
			if (alarm[4] == -1){
				alarm[4] = fps * PERCEPTION_INTEVAL_TIME;
				on_path = false;
				create_path(player_last_place_seen[0], player_last_place_seen[1]);
			}
			return;
			
		case(SPIDER_STATES.SHOOT):
				//do code that shoots :p
				show_debug_message("POW");
		case(SPIDER_STATES.RUN):
				// do code that runs
	}
}

//get next eb to spider go
function get_next_web_position(){
	var _max_web_count = instance_number(obj_spider_web);

	if ( web_counter >= _max_web_count - 1 ){ web_counter = 0;}
	else { web_counter++ }
	
	var _web = instance_find(obj_spider_web, web_counter);
	
	return [_web.x, _web.y]
}

function get_unocupied_position_in_web_range(){
	var _web = instance_find(obj_spider_web, web_counter);
	
	while (true) {
		var _x = irandom_range(_web.x - web_patrol_range,_web.x + web_patrol_range);
		var _y = irandom_range(_web.y - web_patrol_range,_web.y + web_patrol_range);
	
		var _pos_x = floor((_x - obj_manager.patrol_x1) / obj_manager.cell_size);
		var _pos_y = floor((_y -  obj_manager.patrol_y1) / obj_manager.cell_size);	
		
		if(mp_grid_get_cell(obj_manager.map_grid, _pos_x, _pos_y) == 0){
			return [_pos_x * obj_manager.cell_size, _pos_y * obj_manager.cell_size];
		}
	}
}

//get all objects in line of sight
function raycasting_pov(vision_range = VISION_RANGE){
	var objs_in_vision = [];
	
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
function perception(vision_range = VISION_RANGE){
	var _objs_in_vision = self.raycasting_pov(vision_range);
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
	if(mp_grid_path(obj_manager.map_grid, my_path, self.x, self.y, target_x, target_y,  true) ){ 
		on_path = true;
		path_point_index = 1;
		path_number_points = path_get_number(my_path);
	}
}

//manual movement logic
function path_move(){
	//not on a path
	if (!on_path){ return; }
	
	//reached end of the path
	if (path_point_index == path_number_points){
		show_debug_message( obj_manager.cell_size);
		on_path = false;
		path_point_index = noone;
		path_number_points = noone;
			//reset states 
			state_change();
			return;
	}
	
	var _x = path_get_point_x(my_path, path_point_index);
	var _y = path_get_point_y(my_path, path_point_index);
	
	var _dist = point_distance(x, y, _x, _y);
	
	//reched point go to the next
	if (_dist <= VEL + obj_manager.cell_size){
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


can_hear_alert = function() {
    return CURRENT_STATE == SPIDER_STATES.PATROL
        || CURRENT_STATE == SPIDER_STATES.TRAVEL
		|| CURRENT_STATE == SPIDER_STATES.WATCH;
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
                case "right": _new_sprite = spr_spider_idle_right; break;
                case "up":    _new_sprite = spr_spider_idle_up;    break;
                case "left":  _new_sprite = spr_spider_idle_left;  break;
                case "down":  _new_sprite = spr_spider_idle_down;  break;
            }
            break;

        default: 
            switch (_dir) {
                case "right": _new_sprite = spr_spider_walk_right; break;
                case "up":    _new_sprite = spr_spider_walk_up;    break;
                case "left":  _new_sprite = spr_spider_walk_left;  break;
                case "down":  _new_sprite = spr_spider_walk_down;  break;
            }
            break;
    }
	
	if ( _new_sprite != last_sprite ){
		sprite_index = _new_sprite;
		last_sprite = _new_sprite;
	}
}
	
function state_change(){
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
		case(SPIDER_STATES.CHASE):  CURRENT_STATE = SPIDER_STATES.TRAVEL; return;
		case(SPIDER_STATES.SHOOT):  CURRENT_STATE = SPIDER_STATES.RUN; return;
		case(SPIDER_STATES.RUN):	CURRENT_STATE = SPIDER_STATES.TRAVEL; return;
	}

}