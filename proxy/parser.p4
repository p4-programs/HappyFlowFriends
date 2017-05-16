#include "headers.p4"

parser start {
    return parse_ethernet;
}


#define ETHERTYPE_IPV4 0x0800
#define FAKE_IPV4_VER 0x0

parser parse_ethernet {
    extract(ethernet);
    return select(latest.etherType) {
        ETHERTYPE_IPV4 : parse_ipv4;
        default: ingress;
    }
}

parser parse_ipv4 {
    extract(ipv4);
    return select(ipv4.version) {
        FAKE_IPV4_VER : parse_checker; // hack(parse graph), otherwise will overwrite tcp part
        default: ingress;
    }
}

parser parse_checker {
    extract(checker);
	return ingress;
}
