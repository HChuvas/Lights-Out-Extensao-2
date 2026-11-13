// luzes acesas: o monstro do armário é só um armário
if (pg_phase() < 1 || instance_exists(obj_blackout)) { image_speed = 0; exit; }

// Congela caso necessário
if (global.frozen) { image_speed = 0; exit; }

glow_update();

switch (state) {
    case WARDROBE_STATES.WAITING:
        // o brilho dos olhos vai sozinho
        image_speed = 0;
        if (!blinking) {
            timer--;
            if (timer <= 0) {
                blinking = true;
                blink_t = 0;
            }
        } else {
            blink_t++;
            if (blink_t >= blink_len * game_get_speed(gamespeed_fps)) set_idle();
        }
        image_index = 0; //

        var _item = find_dropped_item();
        if (_item != noone) start_trade(_item);
    break;

    case WARDROBE_STATES.TRADING:
        image_speed = 1;
        if (!given && image_index >= give_frame) give_item();
    break;
}
