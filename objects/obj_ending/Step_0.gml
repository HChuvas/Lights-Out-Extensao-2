var _dt = min(delta_time / 1000000, 1 / 20);

if (alpha < 1) {
    alpha = min(1, alpha + _dt / fade_time);
} else {
    timer += _dt;
    if (timer >= hold_time) {
        audio_stop_sound(ambient_sound);
        audio_sound_gain(ambient_sound, 1, 0);
        if (instance_exists(Player)) Player.persistent = false;
        room_goto(r_win_screen);
    }
}
