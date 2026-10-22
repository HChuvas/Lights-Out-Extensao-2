collision_map = layer_tilemap_get_id("Collision");
wall_map = layer_tilemap_get_id("Walls");              
bottom_wall_map = layer_tilemap_get_id("BottomWalls");
if (!instance_exists(glow)) glow = instance_create_layer(x, y, "Instances", obj_player_natural_light);
if (!instance_exists(light)) { light = instance_create_layer(x, y, "Instances", obj_light_cone); light.on = false; }
if (!instance_exists(camera)) camera = instance_create_layer(x, y, "Instances", obj_camera);
if (!instance_exists(obj_lighting)) instance_create_layer(x, y, "Instances", obj_lighting);
