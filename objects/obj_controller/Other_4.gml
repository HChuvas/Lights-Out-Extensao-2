if (room != r_game_over && room != r_title && !audio_is_playing(ambient_sound)) {
    audio_play_sound(ambient_sound, 1, true);
}