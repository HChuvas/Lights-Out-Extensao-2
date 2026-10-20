life_points = 3;
player_speed = 1
item_held = ""
facing = "down"
wall_map = layer_tilemap_get_id("Walls")
bottom_wall_map = layer_tilemap_get_id("BottomWalls")
camera = instance_create_layer(x, y, "Instances", obj_camera)