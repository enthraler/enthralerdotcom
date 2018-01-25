package enthralerdotcom.content;

import enthralerdotcom.templates.Template;
import enthralerdotcom.types.*;
import tink.sql.Types;

// @:index(guid, unique)
// @:index(title)
// @:index(templateId)
// @:index(copiedFromId)
typedef Content = {
	@:autoIncrement @:primary var id(default, null): Id<Content>;
	var created(default, null): DateTime;
	var updated(default, null): DateTime;
	var templateId(default, null): Id<Template>;
	var guid(default, null): ContentGuid;
	var copiedFromId(default, null): Null<Id<Content>>;
}