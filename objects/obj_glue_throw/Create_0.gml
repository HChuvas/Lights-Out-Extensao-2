// Animação do garoto jogando a cola no chão.
// owner e size chegam do Items (glue.on_use).
throw_time = 20;   // frames que o garoto fica parado jogando (ajuste quando o sprite existir)
throw_dist = 14;   // distância (px) dos pés do garoto até o centro da poça

owner.frozen = true;   // o Step do Player para, então o sprite abaixo não é trocado

// sprite de arremesso: spr_kid_glue_throw_down/up/left/right
// enquanto não existir, usa o idle como placeholder
var _spr = asset_get_index("spr_kid_glue_throw_" + owner.facing);
if (_spr == -1) _spr = asset_get_index("spr_kid_idle_" + owner.facing);
owner.sprite_index = _spr;
owner.image_index = 0;
