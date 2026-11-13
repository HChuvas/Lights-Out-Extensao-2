if (image_alpha == 0.5){ 
	image_alpha = 1;
	FRAME_INTEVAL = FRAME_INTEVAL / 1.6;	
} 
else { image_alpha = 0.5;}

alarm[1] = FRAME_INTEVAL * tps;
