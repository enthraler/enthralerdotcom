package enthralerdotcom.templates;

import enthralerdotcom.types.*;
import tink.sql.types.*;

typedef Template = {
	id: Id<Template>,
	created: DateTime,
	updated: DateTime,
	sourceJson: Text<"">
}

enum TemplateSource {
	Github(username:String, repo:String);
}
