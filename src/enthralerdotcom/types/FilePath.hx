package enthralerdotcom.types;

import tink.sql.types.Text;

abstract FilePath(Text<255>) to String {
	public function new(filePath:String) {
		this = filePath;
	}
}
