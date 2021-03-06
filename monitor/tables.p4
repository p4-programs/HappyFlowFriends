#include "parser.p4"

action forward_back() {
    modify_field(standard_metadata.egress_spec, 1);
}


table table_forward_back {
    actions {
        forward_back;
    }

}

action forward_ahead_ipv4() {
	// host num is 2^n, modify egress port
    modify_field(standard_metadata.egress_spec, (ipv4.srcAddr&1) + 2); 
}


table table_forward_ahead_ipv4 {
    actions {
        forward_ahead_ipv4;
        
    }

}

action forward_ahead_arp_ipv4() {
	// host num is 2^n, modify egress port
    modify_field(standard_metadata.egress_spec, (arp_ipv4.dst_ip&1) + 2); 
}


table table_forward_ahead_arp_ipv4 {
    actions {
        forward_ahead_arp_ipv4;
        
    }

}

action action_drop() {
    drop();
}

table table_drop {
    actions {
        action_drop;
    }
}

#define heavy_hitter_max 6

// count min sketch init
action action_get_hash_val() {
    modify_field_with_hash_based_offset(my_metadata.hash_val0, 0, heavy_hitter_hash0, 65536);
    modify_field_with_hash_based_offset(my_metadata.hash_val1, 0, heavy_hitter_hash1, 65536);
    modify_field_with_hash_based_offset(my_metadata.hash_val2, 0, heavy_hitter_hash2, 65536);
}

table table_count_min_sketch_init {
	actions {
        action_get_hash_val;
    }
}

// count min sketch increase count
action action_count_min_sketch_incr() {
    register_read(my_metadata.count_val0, heavy_hitter_register0, my_metadata.hash_val0);
    register_read(my_metadata.count_val1, heavy_hitter_register1, my_metadata.hash_val1);
    register_read(my_metadata.count_val2, heavy_hitter_register2, my_metadata.hash_val2);
    
    add_to_field(my_metadata.count_val0, 1);
    add_to_field(my_metadata.count_val1, 1);
    add_to_field(my_metadata.count_val2, 1);
    
    register_write(heavy_hitter_register0, my_metadata.hash_val0, my_metadata.count_val0);
    register_write(heavy_hitter_register1, my_metadata.hash_val1, my_metadata.count_val1);
    register_write(heavy_hitter_register2, my_metadata.hash_val2, my_metadata.count_val2);
}

table table_count_min_sketch_incr{
    actions {
        action_count_min_sketch_incr;
    }
}


// count min sketch decrease count
action action_count_min_sketch_decr() {
    register_read(my_metadata.count_val0, heavy_hitter_register0, my_metadata.hash_val0);
    register_read(my_metadata.count_val1, heavy_hitter_register1, my_metadata.hash_val1);
    register_read(my_metadata.count_val2, heavy_hitter_register2, my_metadata.hash_val2);
    
    modify_field(my_metadata.count_val0, heavy_hitter_max - 1);
    modify_field(my_metadata.count_val1, heavy_hitter_max - 1);
    modify_field(my_metadata.count_val2, heavy_hitter_max - 1);
    
    register_write(heavy_hitter_register0, my_metadata.hash_val0, my_metadata.count_val0);
    register_write(heavy_hitter_register1, my_metadata.hash_val1, my_metadata.count_val1);
    register_write(heavy_hitter_register2, my_metadata.hash_val2, my_metadata.count_val2);
}

table table_count_min_sketch_decr{
    actions {
        action_count_min_sketch_decr;
    }
}

//timestamp
action action_get_last_timestamp() {
    register_read(my_metadata.timestamp0, timestamp_register0, my_metadata.hash_val0);
    register_read(my_metadata.timestamp1, timestamp_register1, my_metadata.hash_val1);
    register_read(my_metadata.timestamp2, timestamp_register2, my_metadata.hash_val2);
}

table table_get_last_timestamp {
    actions {
        action_get_last_timestamp;
    }
}

action action_update_timestamp() {
    register_write(timestamp_register0, my_metadata.hash_val0, intrinsic_metadata.ingress_global_timestamp);
    register_write(timestamp_register1, my_metadata.hash_val1, intrinsic_metadata.ingress_global_timestamp);
    register_write(timestamp_register2, my_metadata.hash_val2, intrinsic_metadata.ingress_global_timestamp);
}

table table_update_timestamp {
	actions {
		action_update_timestamp;
	}
}

//heavy hitter register reset

action action_register0_reset() {
    register_write(heavy_hitter_register0, my_metadata.hash_val0, 0);
}

table table_register0_reset {
	actions {
		action_register0_reset;
	}
}

action action_register1_reset() {
    register_write(heavy_hitter_register1, my_metadata.hash_val1, 0);
}

table table_register1_reset {
	actions {
		action_register1_reset;
	}
}

action action_register2_reset() {
    register_write(heavy_hitter_register2, my_metadata.hash_val2, 0);
}

table table_register2_reset {
	actions {
		action_register2_reset;
	}
}

