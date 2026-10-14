var _right = keyboard_check(vk_right);
var _left = keyboard_check(vk_left);
var _up = keyboard_check(vk_up);
var _down = keyboard_check(vk_down);

var _hspd = (_right - _left) * player_speed;
var _vspd = (_down - _up) * player_speed;

if (_hspd != 0 || _vspd != 0)
{
	move_and_collide(_hspd, _vspd, [wall_map, collision_map]);
    x = round(x);
    y = round(y);
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
	case "down":  sprite_index = _moving ? spr_kid_walk_down  : spr_kid_idle_down;  break;
	case "up":    sprite_index = _moving ? spr_kid_walk_up    : spr_kid_idle_up;    break;
	case "left":  sprite_index = _moving ? spr_kid_walk_left  : spr_kid_idle_left;  break;
	case "right": sprite_index = _moving ? spr_kid_walk_right : spr_kid_idle_right; break;
}