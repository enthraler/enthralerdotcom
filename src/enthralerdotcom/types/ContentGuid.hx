package enthralerdotcom.types;

import tink.sql.types.Text;
import enthralerdotcom.util.Uuid;

abstract ContentGuid(Text<36>) to String {
	public function new(guid:String) {
		this = guid;
	}

	public static function generate() {
		return new ContentGuid(Uuid.generate());
	}
}
