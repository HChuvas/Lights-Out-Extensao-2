if (consume_frame >= 0) {
    consume_frame += 3 / game_get_speed(gamespeed_fps);

    if (consume_frame >= sprite_get_number(spr_player_consume_item)) {
        consume_frame = -1;
    }
}

if (keyboard_check(ord("L"))) game_restart();

if (life_points <= 0) {
    life_points = 0;
    with (Player) persistent = false;
    audio_stop_sound(ambient_sound);
    audio_play_sound(death_sound, 1, false);
    room_goto(r_game_over);
    exit;
}

if (fade > 0)
{
    fade -= 0.05;
    if (fade <= 0) frozen = false;
}
if (frozen) { target = noone; exit; }


//slow spider web
FINAL_VEL = player_speed * VEL_MODIFIER;


var _right = keyboard_check(vk_right) || keyboard_check(ord("D"));
var _left = keyboard_check(vk_left) || keyboard_check(ord("A"));
var _up = keyboard_check(vk_up) || keyboard_check(ord("W"));
var _down = keyboard_check(vk_down) || keyboard_check(ord("S"));

var _hspd = (_right - _left);
var _vspd = (_down - _up);

if ((_hspd != 0 || _vspd != 0) && item_held == "")
{
    var _solids = [Balloon];

    if (wall_map != noone) array_push(_solids, wall_map);
    if (collision_map != noone) array_push(_solids, collision_map);

    move_and_collide(_hspd, _vspd, _solids, 4, 0, 0, FINAL_VEL, FINAL_VEL);

    if (!place_meeting(x, y, _solids)) { x = x; y = y; }
    glow.x = x; glow.y = y;
/*
    var _rx = round(x), _ry = round(y);
    if (!place_meeting(_rx, _ry, _solids)) {
        x = _rx;
        y = _ry;
    }
*/

}

var _still_held = (facing == "right" && _hspd > 0)
               || (facing == "left"  && _hspd < 0)
               || (facing == "down"  && _vspd > 0)
               || (facing == "up"    && _vspd < 0);

if (!_still_held)
{
    if (_hspd > 0) facing = "right";
    else if (_hspd < 0) facing = "left";
    else if (_vspd > 0) facing = "down";
    else if (_vspd < 0) facing = "up";
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
    var _spr = asset_get_index("spr_kid_" + item_held + "_" + facing);
    if (_spr != -1) sprite_index = _spr;
}


// --- interação (F) ---
// caixa na frente do bbox do jogador, na direção em que ele olha
// _side alarga a caixa para os lados (pega itens um pouco ao lado)
var _side = 6;
var _x1 = bbox_left, _y1 = bbox_top, _x2 = bbox_right, _y2 = bbox_bottom;
switch (facing)
{
	case "right": _x1 = bbox_left;                   _x2 = bbox_right + interact_range;  _y1 -= _side; _y2 += _side; break;
	case "left":  _x1 = bbox_left - interact_range;  _x2 = bbox_right;                  _y1 -= _side; _y2 += _side; break;
	case "down":  _y1 = bbox_top;                    _y2 = bbox_bottom + interact_range; _x1 -= _side; _x2 += _side; break;
	case "up":    _y1 = bbox_top - interact_range;   _y2 = bbox_bottom;                   _x1 -= _side; _x2 += _side; break;
}

// pega o interagível mais perto do centro do jogador
target = noone;
var _list = ds_list_create();
var _n = collision_rectangle_list(_x1, _y1, _x2, _y2, obj_interactable, false, true, _list, false);
var _cx = (bbox_left + bbox_right) / 2;
var _cy = (bbox_top + bbox_bottom) / 2;
var _best = infinity;
for (var i = 0; i < _n; i++)
{
	var _inst = _list[| i];
	var _d = point_distance(_cx, _cy, (_inst.bbox_left + _inst.bbox_right) / 2, (_inst.bbox_top + _inst.bbox_bottom) / 2);
	if (_d < _best) { _best = _d; target = _inst; }
}
ds_list_destroy(_list);

if (target != noone && item_held == "" && keyboard_check_pressed(ord("F")))
{
	target.interact();
}

aply_i_frames();

enemy_separation(5, 2, 4, false, obj_chaser);
enemy_separation(12, 2, 4, false, obj_spider);
enemy_separation(16, 2, 4, false, Clown);
