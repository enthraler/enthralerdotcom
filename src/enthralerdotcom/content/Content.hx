package enthralerdotcom.content;

import enthralerdotcom.templates.Template;
import enthralerdotcom.types.*;
import tink.sql.types.*;

// @:index(guid, unique)
// @:index(title)
// @:index(templateId)
// @:index(copiedFromId)
typedef Content = {
	var id(default, null): Id<Content>;
	var created(default, null): DateTime;
	var updated(default, null): DateTime;
	var templateId(default, null): Id<Template>;
	var guid(default, null): ContentGuid;
	var anonymousAuthorId(default, null): Id<AnonymousContentAuthor>;
	var copiedFromId(default, null): Id<Content>;
}