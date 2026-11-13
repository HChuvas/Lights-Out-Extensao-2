var _player = instance_find(Player, 0);
if (_player != noone) {

    var _life_points = _player.life_points;
	
	var _life_spacing = 8;
	var _x = 16;
	var _y = 16;
	
    for (var i = 0; i < 3; i++) {

        var _sprite;

        if (i + 1 > _life_points) {
            _sprite = spr_empty_moon_heart;
        } else {
            _sprite = spr_moon_heart;
        }

        draw_sprite(
            _sprite,
            0,
            _x + i * (sprite_get_width(spr_empty_moon_heart) + _life_spacing),
            _y
        );
    }
}

// objetivo atual
var _goal = "";
switch (pg_phase()) {
    case 0: _goal = "Siga para o primeiro andar e pegue um lanche"; break;
    case 1: _goal = "Volte para o quarto"; break;
}
if (_goal != "") {
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_text(16, 56, _goal);
}
