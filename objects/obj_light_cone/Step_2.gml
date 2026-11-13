// segue quem está segurando a luz e aponta para onde ele olha

// Segue quem está segurando a luz e aponta para onde ele olha.
if (!instance_exists(owner))
{
    with (enemy_parent) in_flashlight_cone = false;
    exit;
}

x = owner.x;
y = owner.y;

var _target = angle;

switch (owner.facing)
{
    case "down":  _target = 270; break;
    case "up":    _target = 90;  break;
    case "left":  _target = 180; break;
    case "right": _target = 0;   break;
}

if (snap) {
    angle = _target;
    snap = false;
}
else {
    angle += angle_difference(_target, angle) * 0.3;
}

// Atualiza a detecção de todos os inimigos.
with (enemy_parent)
{
    in_flashlight_cone = other.is_target_in_beam(id);
}
