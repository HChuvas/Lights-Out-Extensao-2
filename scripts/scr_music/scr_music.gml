// Trilha sonora: só uma música toca por vez.
//
//   r_title                 -> start_menu_song     (loop)
//   fase 0 (luzes acesas)   -> light_house_song    (loop)
//   fase 1 (luzes apagadas) -> darkness_house_song (loop)
//   meia                    -> speed_song (7s) e depois volta pra música da fase
//   morreu                  -> game_over_song      (toca 1 vez)
//   dormiu na cama          -> victory_song        (loop)

#macro MUSIC_PRIORITY 10 // prioridade alta pra efeitos sonoros não roubarem o canal da música

function music_init() {
    if (variable_global_exists("music_handle")) return;
    global.music_handle = -1;    // instância tocando agora
    global.music_snd    = -1;    // asset tocando agora
    global.music_speed  = false; // true enquanto a speed_song toca
}

function music_stop() {
    music_init();
    if (global.music_handle != -1) audio_stop_sound(global.music_handle);
    global.music_handle = -1;
    global.music_snd    = -1;
    global.music_speed  = false;
}

// troca a música; se já é essa que está tocando, não reinicia (trocar de andar/sala não corta a música)
// _start_s (opcional): segundo em que a música começa; no loop ela volta pro início normal
function music_play(_snd, _loop, _start_s = 0) {
    music_init();
    if (global.music_snd == _snd && audio_is_playing(global.music_handle)) return;

    music_stop();
    global.music_handle = audio_play_sound(_snd, MUSIC_PRIORITY, _loop);
    global.music_snd    = _snd;
    if (_start_s > 0) audio_sound_set_track_position(global.music_handle, _start_s);
}

function music_fade_out(_ms) {
    music_init();
    if (global.music_handle != -1) audio_sound_gain(global.music_handle, 0, _ms);
}

// música do jogo conforme a fase: 0 = luzes acesas, 1 = luzes apagadas
function music_update_gameplay() {
    music_init();
    if (global.music_speed) return; // meia ativa: deixa a speed_song terminar

    var _phase = pg_phase();
    if (_phase == 0)      music_play(light_house_song, true);
    else if (_phase == 1) music_play(darkness_house_song, true);
}

// jogador usou a meia: troca a música de terror pela de velocidade
// (se usar outra meia durante o efeito, a música recomeça junto com o timer)
function music_speed_start() {
    music_init();
    if (global.music_handle != -1) audio_stop_sound(global.music_handle);
    global.music_snd    = speed_song;
    global.music_handle = audio_play_sound(speed_song, MUSIC_PRIORITY, false);
    global.music_speed  = true;
}

// chamado todo frame pelo obj_controller: quando a speed_song acaba, volta pra música da fase
function music_speed_check() {
    if (!variable_global_exists("music_speed") || !global.music_speed) return;
    if (audio_is_playing(global.music_handle)) return;

    global.music_speed  = false;
    global.music_handle = -1;
    global.music_snd    = -1;
    music_update_gameplay();
}
