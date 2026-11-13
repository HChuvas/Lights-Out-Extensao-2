// só existe na volta
if (pg_phase() != 1) {
    instance_destroy();
    exit;
}
event_inherited();
prompt = "Dormir";

// iluminado
instance_create_layer(x + 12, y + 12, "Instances", obj_light);

interact = function() {
    if (pg_phase() == 2) return;
    global.pg_phase = 2;
    audio_stop_sound(ambient_sound);
    Player.persistent = false;
    room_goto(r_win_screen);
};
