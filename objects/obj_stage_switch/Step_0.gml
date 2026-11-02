if (active)
{
    alpha += 0.05;
    if (alpha >= 1)
    {
        if (x_pos >= 0 && y_pos >= 0) {
            Player.x = x_pos;
            Player.y = y_pos;
        }
        if (next_floor > 0) global.pg_floor = next_floor;
        Player.fade = 1;
        room_goto(room_name);
    }
}