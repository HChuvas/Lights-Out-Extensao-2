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
    music_stop();
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


// efeito da meia 
if (socks_speed_timer > 0) socks_speed_timer--;

var _socks_modifier = (socks_speed_timer > 0)
    ? socks_speed_multiplier
    : 1;

// slow da teia + velocidade da meia
FINAL_VEL = player_speed * VEL_MODIFIER * _socks_modifier;


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

    move_and_collide(_hspd * FINAL_VEL, _vspd * FINAL_VEL, _solids, 4, 0, 0, FINAL_VEL, FINAL_VEL);

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

// porta sólida
var _dp_key = string(room) + ":" + (variable_global_exists("pg_frames_map") ? string(global.pg_frames_map) : "-");
door_posts_timer--;
if (_dp_key != door_posts_key || door_posts_timer <= 0) {
    door_posts_key = _dp_key;
    door_posts_timer = 30;
    rebuild_door_posts();
}
for (var _d = 0; _d < array_length(door_posts); _d++) {
    var _dr = door_posts[_d];
    if (bbox_right > _dr.x1 && bbox_left < _dr.x2 && bbox_bottom > _dr.y1 && bbox_top < _dr.y2) {
        var _pl = bbox_right - _dr.x1;
        var _pr = _dr.x2 - bbox_left;
        var _pu = bbox_bottom - _dr.y1;
        var _pd = _dr.y2 - bbox_top;
        var _pm = min(_pl, _pr, _pu, _pd);
        if (_pm == _pl) x -= _pl;
        else if (_pm == _pr) x += _pr;
        else if (_pm == _pu) y -= _pu;
        else y += _pd;
        glow.x = x; glow.y = y;
    }
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

enemy_separation(8, 2, 4, false, obj_chaser);
enemy_separation(12, 2, 4, false, obj_spider);
enemy_separation(16, 2, 4, false, Clown);
