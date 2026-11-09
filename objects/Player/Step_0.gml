if keyboard_check(ord("L")) game_restart();

if (life_points <= 0) {
    life_points = 0;
    persistent = false;
    audio_stop_sound(ambient_sound);
    audio_play_sound(death_sound, 1, false);
    room_goto(r_game_over);
    exit;
}

if (life_points <= 0) {
    life_points = 0;
	persistent = false;
    room_goto(r_game_over);
    exit;
}

if (fade > 0)
{
	fade -= 0.05;
	if (fade <= 0) frozen = false;
}
if (frozen) exit;

var _right = keyboard_check(vk_right) || keyboard_check(ord("D"));
var _left = keyboard_check(vk_left) || keyboard_check(ord("A"));
var _up = keyboard_check(vk_up) || keyboard_check(ord("W"));
var _down = keyboard_check(vk_down) || keyboard_check(ord("S"));

var _hspd = (_right - _left) * player_speed;
var _vspd = (_down - _up) * player_speed;

if ((_hspd != 0 || _vspd != 0) && item_held == "")
{
	var _solids = [Clown, Balloon];
    if (wall_map != noone) array_push(_solids, wall_map);
    if (collision_map != noone) array_push(_solids, collision_map);
	move_and_collide(_hspd, _vspd, _solids, 4, 0, 0, player_speed, player_speed);
    var _rx = round(x), _ry = round(y);
    if (!place_meeting(_rx, _ry, _solids)) { x = _rx; y = _ry; }
    glow.x = x; glow.y = y;
}

var _still_held = (facing == "right" && _hspd > 0)
               || (facing == "left"  && _hspd < 0)
               || (facing == "down"  && _vspd > 0)
               || (facing == "up"    && _vspd < 0)

if (!_still_held)
{
	if (_hspd > 0) facing = "right"
	else if (_hspd < 0) facing = "left"
	else if (_vspd > 0) facing = "down"
	else if (_vspd < 0) facing = "up"
}

var _moving = (_hspd != 0 || _vspd != 0)
switch (facing)
{
	case "down":  
	sprite_index = _moving ? spr_kid_walk_down  : spr_kid_idle_down;  
	break;
	case "up":    
	sprite_index = _moving ? spr_kid_walk_up    : spr_kid_idle_up;
	break;
	case "left":  sprite_index = _moving ? spr_kid_walk_left  : spr_kid_idle_left;
	break;
	case "right": sprite_index = _moving ? spr_kid_walk_right : spr_kid_idle_right;
	break;
}

// mostra o sprite de "segurando item", seja qual for o item
if (item_held != "")
{
    var _spr = asset_get_index("spr_kid_" + item_held + "_" + facing)
    if (_spr != -1) sprite_index = _spr
}
