// Congela inimigo caso necessário (ex: Pílula, troca de sala)
if (global.frozen) { image_speed = 0; exit; }
image_speed = 1;

if (!instance_exists(Player)) exit;
var _fps = game_get_speed(gamespeed_fps);
timer--;

switch (state) {
    case MIMIC_STATES.IDLE:
        if (point_distance(x, y, Player.x, Player.y) <= trigger_dist) {
            state = MIMIC_STATES.ATTACK;
            attacked = false;
            timer = windup_time * _fps;
            sprite_index = spr_mimic_attack;
            image_index = 0;
        } else if (timer <= 0) {
            timer = relocate() ? irandom_range(idle_time[0], idle_time[1]) * _fps : 2 * _fps;
        }
    break;

    case MIMIC_STATES.ATTACK:
        if (!attacked && timer <= 0) {
            attacked = true;
            timer = attack_time * _fps;
            var _dir = (round(point_direction(x, y, Player.x, Player.y) / 90) * 90) mod 360;
            instance_create_layer(x + lengthdir_x(16, _dir), y + lengthdir_y(16, _dir), layer, obj_chaser_attack_HB, {
                owner: id, damage: attack_damage, attack_direction: _dir, lifetime: attack_lifetime
            });
            audio_play_sound(chaser_attack, 1, false);
        } else if (attacked && timer <= 0) {
            state = MIMIC_STATES.IDLE;
            sprite_index = spr_mimic_idle;
            timer = irandom_range(idle_time[0], idle_time[1]) * _fps;
        }
    break;
}