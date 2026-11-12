// no último segundo a poça vai sumindo
var _alpha = 1 * min(1, life / game_get_speed(gamespeed_fps));

if (puddle_sprite == -1) {
    // sem sprite: cada pedaço é o quadrado branco de spr_glue_puddle, pintado e encolhido
    var _scale = cell / sprite_get_width(spr_glue_puddle);
    for (var _j = 0; _j < n; _j++) {
        for (var _i = 0; _i < n; _i++) {
            if (!filled[_j * n + _i]) continue;
            draw_sprite_ext(spr_glue_puddle, 0, left + _i * cell + cell / 2, top + _j * cell + cell / 2,
                _scale, _scale, 0, glue_color, _alpha);
        }
    }
    exit;
}

// com sprite: o sprite é esticado pro tamanho da poça e cada pedaço
// desenha só o seu pedacinho do sprite (o que bateu na parede não aparece)
var _pw = sprite_get_width(puddle_sprite) / n;    // pedaço do sprite por célula
var _ph = sprite_get_height(puddle_sprite) / n;
for (var _j = 0; _j < n; _j++) {
    for (var _i = 0; _i < n; _i++) {
        if (!filled[_j * n + _i]) continue;
        draw_sprite_part_ext(puddle_sprite, 0, _i * _pw, _j * _ph, _pw, _ph,
            left + _i * cell, top + _j * cell, cell / _pw, cell / _ph, c_white, _alpha);
    }
}
