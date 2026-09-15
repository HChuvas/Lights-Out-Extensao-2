var _right = keyboard_check(vk_right)
var _left = keyboard_check(vk_left)
var _up = keyboard_check(vk_up)
var _down = keyboard_check(vk_down)

var _hspd = _right - _left
var _vspd = _down - _up

if (_hspd != 0 || _vspd != 0)
{
	var _dir = point_direction(0, 0, _hspd, _vspd)
	var _xadd = lengthdir_x(player_speed, _dir)
	var _yadd = lengthdir_y(player_speed, _dir)
	x = x + _xadd
	y = y + _yadd
}