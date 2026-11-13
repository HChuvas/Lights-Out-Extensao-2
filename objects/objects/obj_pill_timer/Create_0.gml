// Pílula: congela e esconde os inimigos por 5 segundos
global.frozen = true;
EFFECT_TIME = 5 * game_get_speed(gamespeed_fps);

	var _enemy_normal_data = {
    owner: id,
    time: EFFECT_TIME
	}


with (enemy_parent) {
	    instance_create_layer(x, y, "Instances", obj_enemy_poof);
		
		switch (object_index) {

        case obj_chaser:
            instance_create_layer(x, y, "Instances", obj_normal_chaser, _enemy_normal_data);
            break;

        case obj_spider:
            instance_create_layer(x, y, "Instances", obj_normal_spider, _enemy_normal_data);
            break;

        case Clown:
            instance_create_layer(x, y, "Instances", obj_normal_clow, _enemy_normal_data);
            break;
    }
    image_alpha = 0;
}

fade = 0;            // 0 = invisível, 1 = normal
fading = false;
alarm[0] = EFFECT_TIME
