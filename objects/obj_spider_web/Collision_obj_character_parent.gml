if (other != obj_spider) {
	for ( var i = 0; i <  array_length(affected); i++ ){
		if (array_contains(affected, other)) {
			return;
		}
	}
	aply_slow(affected_by_web, 0.5);
	array_push(affected, other)
}