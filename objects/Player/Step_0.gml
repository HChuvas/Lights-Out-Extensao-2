var _right = keyboard_check(vk_right)
var _left = keyboard_check(vk_left)
var _up = keyboard_check(vk_up)
var _down = keyboard_check(vk_down)

var _hspd = (_right - _left) * player_speed
var _vspd = (_down - _up) * player_speed

if (_hspd != 0 || _vspd != 0)
{
	move_and_collide(_hspd, _vspd, obj_wall)
}