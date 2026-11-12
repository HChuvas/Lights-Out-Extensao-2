x += lengthdir_x(VEL, attack_direction);
y += lengthdir_y(VEL, attack_direction);

var collision_tilemap = layer_tilemap_get_id(layer_get_id("Collision"));
if (place_meeting(x, y, collision_tilemap) ){
	instance_destroy(self.id);
}