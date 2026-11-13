// começo da partida: a criança acorda na cama do quarto
if (room == r_starting_room && !instance_exists(Player)) {
    instance_create_layer(354, 384, "Instances", Player);
}

if (room != r_game_over && room != r_title && room != r_win_screen && !audio_is_playing(ambient_sound)) {
    audio_play_sound(ambient_sound, 1, true);
}