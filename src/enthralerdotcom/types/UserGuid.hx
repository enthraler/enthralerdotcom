package enthralerdotcom.types;

import enthralerdotcom.util.Uuid;
import tink.sql.types.Text;

abstract UserGuid(Text<36>) to String {
	public function new(guid:String) {
		this = guid;
	}

	public static function generate() {
		return new UserGuid(Uuid.generate());
	}
}