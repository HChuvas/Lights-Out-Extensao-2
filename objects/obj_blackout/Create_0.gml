// pisca as luzes até apagar
timer = 0;
wake_at = 100; // frames até os objetos virarem monstros
woke = false;
audio_play_sound(lantern_activate, 1, false);
with (obj_lighting) darkness = 0; // começa ainda iluminado, só depois pisca
dark_music = false;
