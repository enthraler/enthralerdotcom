package enthralerdotcom.templates;

import enthralerdotcom.types.*;
import tink.sql.types.*;

typedef Template = {
	@:autoIncrement @:primary var id(default, null): Id<Template>;
	var created(default, null): DateTime;
	var updated(default, null): DateTime;
	var name(default, null): Text<255>;
	var description(default, null): Text<9999999>;
	var homepage(default, null): Url;
	var sourceJson(default, null): Text<9999999>;
}

enum TemplateSource {
	Github(username:String, repo:String);
}
