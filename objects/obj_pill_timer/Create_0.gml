// Pílula: congela e esconde os inimigos por 5 segundos
global.frozen = true;

with (enemy_parent) {
    instance_create_layer(x, y, "Instances", obj_enemy_poof);
    image_alpha = 0;
}

fade = 0;            // 0 = invisível, 1 = normal
fading = false;
alarm[0] = 5 * game_get_speed(gamespeed_fps);
