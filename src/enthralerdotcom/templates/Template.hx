package enthralerdotcom.templates;

import enthralerdotcom.types.*;
import tink.sql.Types;

typedef Template = {
	@:autoIncrement @:primary var id(default, null): Id<Template>;
	var created(default, null): DateTime;
	var updated(default, null): DateTime;
	var name(default, null): VarChar<255>;
	var description(default, null): Text;
	var homepage(default, null): Url;
	var sourceJson(default, null): Text;
}

enum TemplateSource {
	Github(username:String, repo:String);
}
