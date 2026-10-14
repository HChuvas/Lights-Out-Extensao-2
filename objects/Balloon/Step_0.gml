if (instance_exists(Player) && point_distance(x, y, Player.x, Player.y) < 16) {
    instance_destroy();
}