package enthralerdotcom.types;

import tink.sql.Types;
import enthralerdotcom.util.Uuid;

abstract ContentGuid(VarChar<36>) to String {
	public function new(guid:String) {
		this = guid;
	}

	public static function generate() {
		return new ContentGuid(Uuid.generate());
	}
}
