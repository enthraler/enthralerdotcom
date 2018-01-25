package enthralerdotcom.types;

import tink.sql.Types;

// 39 = length of IPv6 address
abstract IpAddress(VarChar<39>) to String {
	public function new(ip:String) {
		this = ip;
	}
}
