tps = game_get_speed(gamespeed_fps);
FRAME_INTEVAL = 1;
//total time
alarm[0] = time;
//i frames duraction timer 
alarm[1] = FRAME_INTEVAL * tps;
