// Draw the game at full window size instead of 320x180, so the camera can
// move in screen pixels (1/4 of a game pixel) and glide smoothly
surface_resize(application_surface, view_wport[0], view_hport[0]);