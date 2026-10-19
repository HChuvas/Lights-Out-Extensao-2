var _cam = view_camera[0];
var _cx = camera_get_view_x(_cam);
var _cy = camera_get_view_y(_cam);
var _w = camera_get_view_width(_cam);
var _h = camera_get_view_height(_cam);

if (!surface_exists(surf)) surf = surface_create(_w, _h);

surface_set_target(surf);
draw_clear_alpha(c_black, darkness);   // fill the screen with darkness
gpu_set_blendmode(bm_subtract);        // drawing now ERASES darkness
with (obj_light)
{
    draw_set_alpha(ring_alpha)
    for (var i = 0; i < rings; i++)        
    {
        draw_circle(x - _cx, y - _cy, radius * (1 - i / rings), false);
    }
}
draw_set_alpha(1);
gpu_set_blendmode(bm_normal);
surface_reset_target();

draw_surface(surf, _cx, _cy);