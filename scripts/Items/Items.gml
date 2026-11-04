// Todos os itens do jogo ficam aqui, procurados pelo nome.
// on_use(player):  roda uma vez quando E é pressionado
// on_stop(player): roda uma vez quando E é solto
// consumable:      true = gasta 1 de quantity a cada uso

global.items = {

    flashlight: {
        sprite: spr_flashlight_in,
        consumable: false,
        light: noone,
        on_use: function(_player) {
            light = instance_create_layer(_player.x, _player.y, "Instances", obj_light_cone);
            light.owner = _player;
        },
        on_stop: function(_player) {
            if (instance_exists(light)) instance_destroy(light);
            light = noone;
        },
    },

    // placeholder: ainda sem função
    water_cup: {
        sprite: spr_water_cup,
        consumable: false,
        on_use: function(_player) {},
        on_stop: function(_player) {},
    },

};
