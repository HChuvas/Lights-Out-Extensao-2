function draw_raycasting_pov(obj ,vision_range){
	for( var ang = 0; ang <= 360; ang = ang + 9){
		
		var len_x = lengthdir_x(vision_range, ang);
		var len_y = lengthdir_y(vision_range, ang);
	
		var x2 = obj.x + len_x;
		var y2 = obj.y + len_y;
	
		draw_line(obj.x, obj.y, x2, y2);
	}
	return;
}