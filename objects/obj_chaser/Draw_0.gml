draw_set_alpha(0.3);
draw_set_colour(c_red)
draw_path(my_path, self.x, self.y, 1);

draw_set_colour(c_white)
draw_raycasting_pov(self, self.IDLE_VISION_RANGE);
draw_set_alpha(1);
draw_self();