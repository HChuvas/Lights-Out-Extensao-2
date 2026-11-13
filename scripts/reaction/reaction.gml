function reaction(choice){
var _data = {
	owner:  other.id
}

	if (choice == 1){
		instance_create_layer(other.x + 6, self.y - 17, layer, obj_atention, _data);
	} else {
		instance_create_layer(other.x + 6, self.y - 17, layer, obj_sleepy, _data);
	}
}