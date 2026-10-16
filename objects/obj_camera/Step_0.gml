var _hdis = Player.x - x;
var _vdis = Player.y - y;
x += _hdis * 0.1;
y += _vdis * 0.1;

// Move the room camera ourselves: centered on this object, kept inside the
// room, and rounded to whole screen pixels (_scale = 4 at 320x180 -> 1280x720)
var _cam = view_camera[0];
var _cw = camera_get_view_width(_cam);
var _ch = camera_get_view_height(_cam);
var _scale = view_wport[0] / _cw;
var _cx = clamp(round((x - _cw / 2) * _scale) / _scale, 0, room_width - _cw);
var _cy = clamp(round((y - _ch / 2) * _scale) / _scale, 0, room_height - _ch);
camera_set_view_pos(_cam, _cx, _cy);
