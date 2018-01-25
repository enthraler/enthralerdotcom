package enthralerdotcom.types;

import tink.sql.Types;

abstract FilePath(VarChar<255>) to String {
	public function new(filePath:String) {
		this = filePath;
	}
}
