
event_inherited();

shape = SHAPE.CONE;
angle = 0;
radius = 96;
cone_half = 30;
rings = 5;
ring_alpha = 0.2;
owner = noone;
snap = true;

// Verifica se um alvo está dentro do cone da lanterna.
is_target_in_beam = function(_target)
{
    if (!on || !instance_exists(_target)) return false;

    // Verifica o alcance.
    var _distance = point_distance(x, y, _target.x, _target.y);
    if (_distance > radius) return false;

    // Verifica o ângulo do cone.
    var _target_angle = point_direction(x, y, _target.x, _target.y);

    if (abs(angle_difference(angle, _target_angle)) > cone_half) {
        return false;
    }

    // Obtém o objeto responsável pelas paredes.
    var _lighting = instance_find(obj_lighting, 0);
    if (!instance_exists(_lighting)) return false;

    // Verifica se existe alguma parede entre a luz e o alvo.
    var _steps = max(1, ceil(_distance / 2));

    for (var i = 1; i < _steps; i++)
    {
        var _sample_distance = _distance * i / _steps;

        var _sample_x = x + lengthdir_x(
            _sample_distance,
            _target_angle
        );

        var _sample_y = y + lengthdir_y(
            _sample_distance,
            _target_angle
        );

        if (_lighting.is_solid(_sample_x, _sample_y)) {
            return false;
        }
    }

    return true;
};
