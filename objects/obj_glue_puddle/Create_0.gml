event_inherited();                 // lógica da teia: affected / affected_by_web
affected_by_web = [enemy_parent];  // gruda só inimigos, nunca o garoto
slow_amount = 0.5;                 // velocidade na cola (0.5 = metade, 0.25 = um quarto)

// size = raio da poça em px. Vem do Items; se a poça for posta na sala direto, usa 20
if (!variable_instance_exists(id, "size")) size = 20;

x = round(x);
y = round(y);
depth = layer_get_depth("Instances") + 1;   // desenha embaixo dos personagens
glue_color = make_color_rgb(235, 232, 210);

// quanto tempo a poça dura (a cola seca e some)
life_max = 10 * game_get_speed(gamespeed_fps);   // 10 segundos
life = life_max;

// A poça é uma grade de quadradinhos (cell x cell) em volta do centro
cell = 4;
half = ceil(size / cell);
n = half * 2 + 1;
left = x - half * cell - cell / 2;
top  = y - half * cell - cell / 2;

// máscara quadrada do tamanho da grade (para o evento de colisão da teia funcionar)
mask_index = spr_glue_puddle;
image_xscale = n * cell / sprite_get_width(spr_glue_puddle);
image_yscale = image_xscale;

// Flood fill: a cola escorre do centro pra fora, sem atravessar parede
filled = array_create(n * n, false);
var _wobble = random(360);   // deixa a borda meio irregular
var _todo = [];
if (!is_wall_at(x, y)) {
    filled[half * n + half] = true;
    array_push(_todo, half * n + half);
}
while (array_length(_todo) > 0) {
    var _c = array_pop(_todo);
    var _ci = _c mod n, _cj = _c div n;
    var _next = [[_ci + 1, _cj], [_ci - 1, _cj], [_ci, _cj + 1], [_ci, _cj - 1]];
    for (var k = 0; k < 4; k++) {
        var _a = _next[k][0], _b = _next[k][1];
        if (_a < 0 || _b < 0 || _a >= n || _b >= n) continue;
        if (filled[_b * n + _a]) continue;
        var _edge = size * (0.85 + 0.15 * dsin(point_direction(half, half, _a, _b) * 3 + _wobble));
        if (point_distance(half, half, _a, _b) * cell > _edge) continue;
        if (is_wall_at(left + _a * cell + cell / 2, top + _b * cell + cell / 2)) continue;
        filled[_b * n + _a] = true;
        array_push(_todo, _b * n + _a);
    }
}

// true se os pés da instância estão em cima da cola
on_glue = function(_inst) {
    var _i = floor((_inst.x - left) / cell);
    var _j = floor((_inst.bbox_bottom - 2 - top) / cell);
    if (_i < 0 || _j < 0 || _i >= n || _j >= n) return false;
    return filled[_j * n + _i];
};
