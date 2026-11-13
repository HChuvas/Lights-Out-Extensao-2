timer++;

// pisca
var _on = true;
if (timer >= 22 && timer < 28) _on = false;
else if (timer >= 36 && timer < 40) _on = false;
else if (timer >= 48) _on = false;

with (obj_lighting) darkness = _on ? 0 : dark_max;

// começa a música da escuridão
if (!dark_music && timer >= 48) {
    dark_music = true;
    music_play(darkness_house_song, true);
}

if (!woke && timer >= wake_at) {
    woke = true;
    pg_wake_enemies();
    instance_destroy();
}
