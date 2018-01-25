package enthralerdotcom.contentanalytics;

import enthralerdotcom.content.Content;
import enthralerdotcom.content.ContentVersion;
import enthralerdotcom.templates.Template;
import enthralerdotcom.templates.TemplateVersion;
import tink.sql.Types;

typedef ContentAnalyticsEvent = {
	@:autoIncrement @:primary var id(default, null): Id<Content>;
	var created(default, null): DateTime;
	var contentId(default, null): Id<Content>;
	var contentVersionId(default, null): Id<ContentVersion>;
	var templateId(default, null): Id<Template>;
	var templateVersionId(default, null): Id<TemplateVersion>;
	var eventJson(default, null): Text;
}
