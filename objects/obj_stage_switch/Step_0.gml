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

        if (room == r_procedural && room_name == r_procedural) pg_save_floor();
        else pg_clear_saves();

        global.pg_arrive = arrive;
        if (next_floor > 0) global.pg_floor = next_floor;
        Player.fade = 1;
        room_goto(room_name);
    }
}