tps = game_get_speed(gamespeed_fps);
FRAME_INTEVAL = 1;

if (!variable_instance_exists(id, "permanent")) permanent = false;
if (!variable_instance_exists(id, "real_obj")) real_obj = noone;
if (!variable_instance_exists(id, "time")) time = -1;

if (!permanent) {
    //total time
    alarm[0] = time;
    //i frames duraction timer
    alarm[1] = FRAME_INTEVAL * tps;
}
