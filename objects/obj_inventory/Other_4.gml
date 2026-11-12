if (room == r_game_over || room == r_title) {
    instance_destroy();
    exit;
}

item_room_restore();
