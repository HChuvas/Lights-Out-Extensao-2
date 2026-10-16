global.solid_maps = [];
var _names = ["Walls", "Collision"];
for (var _k = 0; _k < array_length(_names); _k++) {
    if (layer_exists(_names[_k])) {
        var _map = layer_tilemap_get_id(_names[_k]);
        if (_map != -1) array_push(global.solid_maps, _map);
    }
}

global.cell = 8;