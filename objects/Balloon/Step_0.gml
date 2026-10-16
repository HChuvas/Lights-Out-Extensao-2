if (popping) exit;


if (instance_exists(Player) && point_distance(x, y, Player.x, Player.y) < 24) {
    popping = true;
    sprite_index = spr_balloon_pop;
    image_index = 0;
    image_speed = 1;
}