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
	if (!on) continue;

	if (shape == SHAPE.CONE)
	{
		// lança raios até bater numa parede
		var _rays = 32;
		var _hits = array_create(_rays + 1);
		for (var r = 0; r <= _rays; r++)
		{
			var _dir = angle - cone_half + (r / _rays) * cone_half * 2;
			var _d = 0;
			while (_d < radius && !other.is_solid(x + lengthdir_x(_d, _dir), y + lengthdir_y(_d, _dir))) _d += 2;
			_hits[r] = _d;
		}
		draw_set_alpha(ring_alpha);
		for (var i = 0; i < rings; i++)
		{
			var _len_max = radius * (1 - i / rings);
			var _trim = floor(_rays * 0.1 * i / rings);
			draw_primitive_begin(pr_trianglefan);
			draw_vertex(x - _cx, y - _cy);
			for (var r = _trim; r <= _rays - _trim; r++)
			{
				var _dir = angle - cone_half + (r / _rays) * cone_half * 2;
				var _len = min(_hits[r], _len_max);
				draw_vertex(x - _cx + lengthdir_x(_len, _dir), y - _cy + lengthdir_y(_len, _dir));
			}
			draw_primitive_end();
		}
	}
	else
	{
		draw_set_alpha(ring_alpha);
		for (var i = 0; i < rings; i++)
		{
			draw_circle(x - _cx, y - _cy, radius * (1 - i / rings), false);
		}
	}
}
draw_set_alpha(1);
gpu_set_blendmode(bm_normal);
surface_reset_target();

draw_surface(surf, _cx, _cy);
