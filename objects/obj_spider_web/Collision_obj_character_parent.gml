if (pg_phase() < 1) exit;
if (other != obj_spider) {
	for ( var i = 0; i <  array_length(affected); i++ ){
		if (array_contains(affected, other)) {
			return;
		}
	}
	aply_slow(affected_by_web, slow_amount);
	array_push(affected, other)
}