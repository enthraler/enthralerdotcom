package enthralerdotcom.content;

import enthralerdotcom.templates.Template;
import enthralerdotcom.types.*;
import tink.sql.types.*;

// @:index(guid, unique)
// @:index(title)
// @:index(templateId)
// @:index(copiedFromId)
typedef Content = {
	id: Id<Content>,
	created: DateTime,
	updated: DateTime,
	templateId: Id<Template>,
	guid: ContentGuid,
	anonymousAuthor: Id<AnonymousContentAuthor>,
	copiedFromId: Id<Content>,
}