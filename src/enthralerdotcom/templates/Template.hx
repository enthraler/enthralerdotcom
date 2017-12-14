package enthralerdotcom.templates;

import enthralerdotcom.types.*;
import tink.sql.types.*;

typedef Template = {
	var id(default, null): Id<Template>;
	var created(default, null): DateTime;
	var updated(default, null): DateTime;
	var sourceJson(default, null): Text<9999999>;
}

enum TemplateSource {
	Github(username:String, repo:String);
}
