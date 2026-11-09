if (!armed && !place_meeting(x, y, Player)) armed = true;

if (active)
{
    alpha += 0.05;
    if (alpha >= 1)
    {
        if (x_pos >= 0 && y_pos >= 0) {
            Player.x = x_pos;
            Player.y = y_pos;
        }

        if (!variable_global_exists("pg_resume_floor")) global.pg_resume_floor = 0;

        var _from_proc = (room == r_procedural);
        var _to_proc   = (room_name == r_procedural);
        var _arrive    = arrive;

        // saindo de qualquer andar
        if (_from_proc) pg_save_floor();

        if (_from_proc && !_to_proc)
        {
            // saiu dos 3 andares
            global.pg_resume_floor = procgen_floor();
        }
        else if (!_from_proc && _to_proc)
        {
            // voltando
            if (next_floor > 0)
            {
                global.pg_floor = next_floor;
            }
            else if (global.pg_resume_floor > 0)
            {
                // volta pro andar onde parou
                global.pg_floor = global.pg_resume_floor;
                _arrive = "goal";
            }
            else
            {
                global.pg_floor = 1;
            }
        }
        else if (next_floor > 0)
        {
            // troca normal de andar
            global.pg_floor = next_floor;
        }

        global.pg_arrive = _arrive;
        Player.fade = 1;
        room_goto(room_name);
    }
}