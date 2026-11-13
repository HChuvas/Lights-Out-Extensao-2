// começo da partida: a criança acorda na cama do quarto
if (room == r_starting_room && !instance_exists(Player)) {
    instance_create_layer(354, 384, "Instances", Player);
}

// trilha sonora do jogo
if (room != r_game_over && room != r_title && room != r_win_screen) {
    music_update_gameplay();
}