// no último segundo a poça vai sumindo
var _alpha = 1 * min(1, life / game_get_speed(gamespeed_fps));
var _scale = cell / sprite_get_width(spr_glue_puddle);

// cada pedaço é o quadrado branco de spr_glue_puddle (origem no centro), pintado e encolhido
// (draw_rectangle deixava frestas entre os pedaços quando a tela é ampliada)
for (var _j = 0; _j < n; _j++) {
    for (var _i = 0; _i < n; _i++) {
        if (!filled[_j * n + _i]) continue;
        draw_sprite_ext(spr_glue_puddle, 0, left + _i * cell + cell / 2, top + _j * cell + cell / 2,
            _scale, _scale, 0, glue_color, _alpha);
    }
}
