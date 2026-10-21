if (!ATTACKING){
	
	var _attack_data =  {
    owner: id,
    damage: ATTACK_DAMAGE,
    attack_direction: direction,
	lifetime: ATTACK_LIFETIME
	}
	
var _width  = bbox_right - bbox_left + 1;
var _height = bbox_bottom - bbox_top + 1;
	//right
	if (direction > 315 or direction <= 45) { 
		_attack_data.attack_direction = 0;
		instance_create_layer(self.x + _width, self.y, layer, obj_chaser_attack_HB, _attack_data);
	}
	//up
	else if (direction <= 135) {
		_attack_data.attack_direction = 90;
		instance_create_layer(self.x, self.y - _height, layer, obj_chaser_attack_HB, _attack_data);
	}
	//left
    else if (direction <= 225) { 
		_attack_data.attack_direction = 180;
		instance_create_layer(self.x - _width, self.y, layer, obj_chaser_attack_HB, _attack_data);	
	}
	//down
    else { 
		_attack_data.attack_direction = 270;
		instance_create_layer(self.x, self.y + _height, layer, obj_chaser_attack_HB, _attack_data);	
	}
	
	ATTACKING = true;
	alarm[4] = ATTACK_DURATION_TIME * fps;
} else {
	ATTACKING = false;
	VEL = 1;
	reaction(2);
	CURRENT_STATE =CHASER_STATES.REST;
	on_path = false;
	path_point_index = noone;
	path_number_points = noone;
}