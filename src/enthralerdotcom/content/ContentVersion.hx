package enthralerdotcom.content;

import enthralerdotcom.templates.TemplateVersion;
import enthralerdotcom.types.*;
import tink.sql.types.*;

// @:index(contentID, published)
typedef ContentVersion = {
	var id(default, null): Id<ContentVersion>;
	var created(default, null): DateTime;
	var updated(default, null): DateTime;
	var contentId(default, null): Id<Content>;
	var templateVersionId(default, null): Id<TemplateVersion>;
	var title(default, null): Text<255>;
	var jsonContent(default, null): Text<9999999>;
	var published(default, null): Null<DateTime>;
}