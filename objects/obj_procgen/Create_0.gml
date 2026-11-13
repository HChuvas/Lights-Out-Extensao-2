cfg = procgen_config();      
plan = undefined;
// o F2 vale para todos os andares (variável global, não reinicia a cada andar)
if (!variable_global_exists("pg_debug_view")) global.pg_debug_view = false;
debug_scale = 5;

// botões do mapa de debug
debug_btn_h = 18;
debug_btn_gap = 4;
debug_buttons = [
    { label: "Pular > Biscoito",     action: function() { pg_debug_goto_snack(); } },
    { label: "Pular > Quarto final", action: function() { pg_debug_goto_bedroom(); } },
    { label: "", get_label: function() { return "God mode: " + (pg_god() ? "ON" : "OFF"); },
      action: function() { global.pg_god = !pg_god(); } }
];
debug_btn_rect = function(_i) {
    var _w  = max(150, cfg.cols * debug_scale + 8);
    var _y1 = 8 + cfg.rows * debug_scale + 24 + 6 + _i * (debug_btn_h + debug_btn_gap);
    return [8, _y1, 8 + _w, _y1 + debug_btn_h];
};