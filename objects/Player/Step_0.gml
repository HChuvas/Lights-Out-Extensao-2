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
	move_and_collide(_hspd, _vspd, [wall_map, collision_map, Clown, Balloon], 4, 0, 0, player_speed, player_speed);
    var _rx = round(x), _ry = round(y);
    if (!place_meeting(_rx, _ry, [wall_map, collision_map, Clown, Balloon])) { x = _rx; y = _ry; }
    light.x = x; light.y = y;
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

var _target = light.angle

var _moving = (_hspd != 0 || _vspd != 0)
switch (facing)
{
	case "down":  
	sprite_index = _moving ? spr_kid_walk_down  : spr_kid_idle_down;  
	_target = 270;
	break;
	case "up":    
	sprite_index = _moving ? spr_kid_walk_up    : spr_kid_idle_up;
	_target = 90;
	break;
	case "left":  sprite_index = _moving ? spr_kid_walk_left  : spr_kid_idle_left;
	_target = 180;
	break;
	case "right": sprite_index = _moving ? spr_kid_walk_right : spr_kid_idle_right;
	_target = 0;
	break;
}

light.angle += angle_difference(_target, light.angle) * 0.3;



if (item_held != "" && keyboard_check(ord("E")))
{
    var _spr = asset_get_index("spr_kid_" + item_held + "_" + facing)
    if (_spr != -1) sprite_index = _spr
}
else 
{
	item_held = ""
}

// lanterna só acende enquanto o item é usado
light.on = (item_held == "flashlight");

aply_i_frames();