if (active)
{
    alpha += 0.05;
    if (alpha >= 1)
    {
        Player.x = x_pos;
        Player.y = y_pos;
        Player.fade = 1;
        room_goto(room_name);
    }
}