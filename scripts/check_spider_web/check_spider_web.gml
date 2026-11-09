function check_spider_web() {
    if (place_meeting(x, y, obj_spider_web)) {
        VEL_MODIFIER = 0.60;
    } else {
        VEL_MODIFIER = 1;
    }
}