if ( is_hit == false  and !other.imune){
	is_hit = true;
	other.hited = true;
	other.life_points = other.life_points - damage;
}