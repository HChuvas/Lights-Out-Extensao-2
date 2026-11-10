var _len =  array_length(affected)
var _to_be_removed = []
if ( _len != 0 ){
	for ( var i = 0; i < _len; i++ ){
		if (!place_meeting(x, y, affected[i])) {
			affected[i].VEL_MODIFIER = 1;
			array_delete(affected, i, 1);
			return;
		}
	}	
}