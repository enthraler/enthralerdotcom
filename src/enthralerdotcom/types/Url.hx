package enthralerdotcom.types;

import tink.sql.types.Text;

abstract Url(Text<255>) to String {
	public function new(url:String) {
		this = url;
	}
}
