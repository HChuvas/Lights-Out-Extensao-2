enemy_put_on_layer(); // passa por baixo de portas e batentes
VEL_MODIFIER = 1;
FINAL_VEL = 1;

can_hear_alert = function() { return false; }
hear_alert = function(_x, _y) { return false; }

// Indica se o inimigo está sendo iluminado pela lanterna.
in_flashlight_cone = false;