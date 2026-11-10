function aply_slow(array_objects, vel_modifier = 0.5) {
	
	var aply_to_other = false;
	
	for (var i =0; i < array_length(array_objects); i++){
		if ( object_is_ancestor(other.object_index, array_objects[i]) or array_objects[i].object_index == other.object_index ) {
			aply_to_other = true;
			break;
		}		
	}
	
	if ( !aply_to_other ) {	return false }

    other.VEL_MODIFIER = vel_modifier;
	return true;
}
