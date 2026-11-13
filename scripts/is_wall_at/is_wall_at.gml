// true se o ponto (x, y) cai num tile que bloqueia o garoto
// (as mesmas camadas que o Player usa no move_and_collide)
function is_wall_at(_x, _y) {
    if (!instance_exists(Player)) return false;
    var _maps = [Player.wall_map, Player.collision_map];
    for (var i = 0; i < array_length(_maps); i++) {
        if (_maps[i] == noone) continue;
        if (tile_get_index(tilemap_get_at_pixel(_maps[i], _x, _y)) != 0) return true;
    }
    return false;
}
