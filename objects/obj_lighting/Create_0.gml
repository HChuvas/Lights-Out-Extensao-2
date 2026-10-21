depth = -10000;   // draw on top of everything
darkness = 0.8;  // 1 = pitch black, 0 = no darkness
surf = -1;

// tilemaps que bloqueiam a luz
solid_maps = [];
var _names = ["Walls", "BottomWalls", "Collision"];
for (var i = 0; i < array_length(_names); i++)
{
	var _layer = layer_get_id(_names[i]);
	if (_layer != -1) array_push(solid_maps, layer_tilemap_get_id(_layer));
}

is_solid = function(_px, _py)
{
	for (var i = 0; i < array_length(solid_maps); i++)
	{
		if (tile_get_index(tilemap_get_at_pixel(solid_maps[i], _px, _py)) != 0) return true;
	}
	return false;
}
