if (room == r_game_over || room == r_title || room == r_win_screen) {
    instance_destroy();
    exit;
}

item_room_restore();
