if (i_frames_count == i_frames_times){
	image_alpha = 1;
	i_frames_count = 0;
	imune = false;
} else {
	if (image_alpha == 0.5){ image_alpha = 0.2;} else
	if (image_alpha == 0.2){ image_alpha = 0.5;}
	i_frames_count ++;
	alarm[0] = tps / 2.5;
}