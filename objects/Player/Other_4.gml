global.frozen = false;
collision_map   = layer_tilemap_first(["Collision"]);
wall_map        = layer_tilemap_first(["Walls"]);
bottom_wall_map = layer_tilemap_first(["BottomWalls"]);

if (!instance_exists(glow)) glow = instance_create_layer(x, y, "Instances", obj_player_natural_light);
if (!instance_exists(camera)) camera = instance_create_layer(x, y, "Instances", obj_camera);
if (!instance_exists(obj_lighting)) instance_create_layer(x, y, "Instances", obj_lighting);

var _chk = [];
if (wall_map != noone) array_push(_chk, wall_map);
if (collision_map != noone) array_push(_chk, collision_map);
if (array_length(_chk) > 0 && place_meeting(x, y, _chk)) {
    var _found = false;
    for (var _r = 2; _r <= 64 && !_found; _r += 2) {
        for (var _a = 0; _a < 360 && !_found; _a += 30) {
            var _nx = x + lengthdir_x(_r, _a), _ny = y + lengthdir_y(_r, _a);
            if (!place_meeting(_nx, _ny, _chk)) { x = _nx; y = _ny; _found = true; }
        }
    }
}
