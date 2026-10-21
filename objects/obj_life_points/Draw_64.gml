var _player = instance_find(Player, 0);
if (_player != noone) {

    var _life_points = _player.life_points;
	
	var _life_spacing = 8;
	var _x = 16;
	var _y = 16;
	
    for (var i = 0; i < 3; i++) {

        var _sprite;

        if (i + 1 > _life_points) {
            _sprite = spr_life_points_empty;
        } else {
            _sprite = spr_life_points_full;
        }

        draw_sprite(
            _sprite,
            0,
            _x + i * (sprite_get_width(spr_life_points_empty) + _life_spacing),
            _y
        );
    }
}