package enthralerdotcom.content;

import enthralerdotcom.templates.TemplateVersion;
import enthralerdotcom.types.*;
import tink.sql.Types;

// @:index(contentID, published)
typedef ContentVersion = {
	@:autoIncrement @:primary var id(default, null): Id<ContentVersion>;
	var created(default, null): DateTime;
	var updated(default, null): DateTime;
	var contentId(default, null): Id<Content>;
	var templateVersionId(default, null): Id<TemplateVersion>;
	var title(default, null): VarChar<255>;
	var jsonContent(default, null): LongText;
	var published(default, null): Null<DateTime>;
	var anonymousAuthorId(default, null): Id<AnonymousContentAuthor>;
}