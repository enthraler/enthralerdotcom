package enthralerdotcom.content;

import enthralerdotcom.templates.TemplateVersion;
import enthralerdotcom.types.*;
import tink.sql.types.*;

// @:index(contentID, published)
typedef ContentVersion = {
	id: Id<ContentVersion>,
	created: DateTime,
	updated: DateTime,
	content: Id<Content>,
	templateVersion: Id<TemplateVersion>,
	title: Text<255>,
	jsonContent: Text<"">,
	published: Null<Date>,
}