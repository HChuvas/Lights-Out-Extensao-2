// Todos os itens do jogo ficam aqui, procurados pelo nome.
// on_use(player): roda uma vez quando E é pressionado
// on_stop(player): roda uma vez quando E é solto
// consumable: true = gasta 1 de quantity a cada uso
// destroy_on_consume: true = item é destruído e retirado do inventário quando quantity chega em 0
// pickup: objeto que aparece no chão quando o item é largado (tecla G)

global.items = {

    flashlight: {
        pickup: obj_flashlight,
        sprite: spr_flashlight_in,
        consumed_sprite: spr_flashlight_out,
        consumable: true,
        destroy_on_consume: false,
        usable: true,
        light: noone,
        on_use: function(_player) {
            light = instance_create_layer(_player.x, _player.y, "Instances", obj_light_cone);
            light.owner = _player;
        },
        check_availability: noone,
        on_stop: function(_player) {
            if (instance_exists(light)) instance_destroy(light);
            light = noone;
        },
    },

    water_cup: {
        pickup: obj_water_cup,
        sprite: spr_water_cup,
        consumable: true,
        destroy_on_consume: true,
        usable: false,
        on_use: function(_player) {
            if (_player.life_points < 3) _player.life_points += 1;
        },
        check_availability: function(_player) {
            if (_player.life_points < 3) 
            {
                usable = true;    
            }
            else usable = false;
        },
        on_stop: function(_player) {},
    },

    pill: {
        pickup: obj_pill,
        sprite: spr_pill,
        consumable: true,
        destroy_on_consume: true,
        usable: true,
        timer_instance: noone,
        on_use: function (_player) {
            if (instance_exists(timer_instance))
            {
                instance_destroy(timer_instance);
                timer_instance = noone;
            }
            else timer_instance = instance_create_layer(_player.x, _player.y, "Instances", obj_pill_timer);
        },
        check_availability: noone,
        on_stop: function(_player) {},
    },

    glue: {
        pickup: obj_glue,
        sprite: spr_glue,
        consumable: true,
        destroy_on_consume: true,
        usable: true,
        puddle_min: 40,   // raio mínimo da poça (px)
        puddle_max: 50,   // raio máximo da poça (px)
        on_use: function(_player) {
            instance_create_layer(_player.x, _player.y, "Instances", obj_glue_throw,
                { owner: _player, size: irandom_range(puddle_min, puddle_max) });
        },
        check_availability: function(_player) {
            usable = !instance_exists(obj_glue_throw);   // não joga outra no meio do arremesso
        },
        on_stop: function(_player) {},
    },
    
};
