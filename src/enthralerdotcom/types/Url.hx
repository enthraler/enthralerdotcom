package enthralerdotcom.types;

import tink.sql.Types;

abstract Url(VarChar<255>) to String {
	public function new(url:String) {
		this = url;
	}
}
