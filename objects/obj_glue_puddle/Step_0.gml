// substitui o Step da teia (que usa a máscara quadrada):
// solta quem saiu de cima da cola
for (var i = array_length(affected) - 1; i >= 0; i--) {
    var _e = affected[i];
    if (instance_exists(_e) && on_glue(_e)) continue;
    if (instance_exists(_e)) _e.VEL_MODIFIER = 1;
    array_delete(affected, i, 1);
}

// a cola seca: quando o tempo acaba, solta todo mundo e some
life--;
if (life <= 0) {
    for (var _k = 0; _k < array_length(affected); _k++) {
        if (instance_exists(affected[_k])) affected[_k].VEL_MODIFIER = 1;
    }
    instance_destroy();
}
