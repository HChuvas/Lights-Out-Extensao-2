if (!fading) exit;

fade = min(1, fade + 1 / 25);   // 25 frames para aparecer
with (enemy_parent) image_alpha = other.fade;

if (fade >= 1) {
    global.frozen = false;
    instance_destroy();
}
