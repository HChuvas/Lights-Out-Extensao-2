if (!instance_exists(owner)) { instance_destroy(); exit; }

throw_time--;
if (throw_time > 0) exit;

// direção em que o garoto olha
var _dx = 0, _dy = 0;
switch (owner.facing) {
    case "right": _dx =  1; break;
    case "left":  _dx = -1; break;
    case "down":  _dy =  1; break;
    case "up":    _dy = -1; break;
}

// sai dos pés do garoto e anda até throw_dist, parando antes de parede
var _px = owner.x, _py = owner.bbox_bottom - 2;
repeat (throw_dist) {
    if (is_wall_at(_px + _dx, _py + _dy)) break;
    _px += _dx;
    _py += _dy;
}

instance_create_layer(_px, _py, "Instances", obj_glue_puddle, { size: size });
owner.frozen = false;
instance_destroy();
