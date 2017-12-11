package enthralerdotcom.types;

import tink.sql.types.Text;

// 39 = length of IPv6 address
abstract IpAddress(Text<39>) to String {
	public function new(ip:String) {
		this = ip;
	}
}
