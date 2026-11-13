cfg = procgen_config();      
plan = undefined;
// o F2 vale para todos os andares (variável global, não reinicia a cada andar)
if (!variable_global_exists("pg_debug_view")) global.pg_debug_view = true;  
debug_scale = 5;