if (!ATTACKING){

	var _attack_data = [ {
    owner: id,
    damage: ATTACK_DAMAGE,
    attack_direction: direction,
	lifetime: ATTACK_LIFETIME,
	vel: ATTACK_VEL
	},
	{
    owner: id,
    damage: ATTACK_DAMAGE,
    attack_direction: direction,
	lifetime: ATTACK_LIFETIME,
	vel: ATTACK_VEL
	},
	{
    owner: id,
    damage: ATTACK_DAMAGE,
    attack_direction: direction,
	lifetime: ATTACK_LIFETIME,
	vel: ATTACK_VEL
	}
	
	
	]

var _width  = (bbox_right - bbox_left) / 2;
var _height = (bbox_bottom - bbox_top) / 2;

var _spawn_x = x;
var _spawn_y = y;

	//right
	if (direction > 315 or direction <= 45) { 
		_attack_data[0].attack_direction = 0;
		_attack_data[1].attack_direction = 15;
		_attack_data[2].attack_direction = 345;
		
		_spawn_x = x + _width;
	}
	
	//up
	else if (direction <= 135) {
		_attack_data[0].attack_direction = 90;
		_attack_data[1].attack_direction = 105;
		_attack_data[2].attack_direction = 75;
		
		_spawn_y = y - _height;
	}
	//left
    else if (direction <= 225) { 
		_attack_data[0].attack_direction = 180;
		_attack_data[1].attack_direction = 195;
		_attack_data[2].attack_direction = 165;
		
		_spawn_x = x - _width;
	}
	//down
    else { 
		_attack_data[0].attack_direction = 270;
		_attack_data[1].attack_direction = 285;
		_attack_data[2].attack_direction = 255;
		
		_spawn_y = y + _height;
	}
	
		instance_create_layer(_spawn_x, _spawn_y, layer, obj_spider_attack, _attack_data[0]);
		instance_create_layer(_spawn_x, _spawn_y, layer, obj_spider_attack, _attack_data[1]);
		instance_create_layer(_spawn_x, _spawn_y, layer, obj_spider_attack, _attack_data[2]);
	ATTACKING = true;
	alarm[5] = 1;
} else {
	ATTACKING = false;
	on_path = false;
	path_point_index = noone;
	path_number_points = noone;
	state_change();
}