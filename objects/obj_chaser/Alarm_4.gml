var _attack_data =  {
    owner: id,
    damage: ATTACK_DAMAGE,
    attack_direction: direction,
	lifetime: ATTACK_LIFETIME
}

//right
if (direction > 315 or direction <= 45) { 
	_attack_data.attack_direction = 0;
	instance_create_layer(self.x + sprite_width, self.y, layer, obj_chaser_attack_HB, _attack_data);
	}
	//up
    else if (direction <= 135) {
		_attack_data.attack_direction = 90;
		instance_create_layer(self.x, self.y - sprite_height, layer, obj_chaser_attack_HB, _attack_data);
	}
	//left
    else if (direction <= 225) { 
		_attack_data.attack_direction = 180;
		instance_create_layer(self.x - sprite_width, self.y, layer, obj_chaser_attack_HB, _attack_data);	
	}
	//down
    else { 
		_attack_data.attack_direction = 270;
		instance_create_layer(self.x, self.y + sprite_height, layer, obj_chaser_attack_HB, _attack_data);	
	}

VEL = 1;
CURRENT_STATE =CHASER_STATES.REST;
on_path = false;
path_point_index = noone;
path_number_points = noone;