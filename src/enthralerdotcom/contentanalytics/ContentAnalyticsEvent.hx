package enthralerdotcom.contentanalytics;

import enthralerdotcom.content.Content;
import enthralerdotcom.content.ContentVersion;
import enthralerdotcom.templates.Template;
import enthralerdotcom.templates.TemplateVersion;
import tink.sql.types.*;

typedef ContentAnalyticsEvent = {
	id: Id<Content>,
	created: DateTime,
	contentId: Id<Content>,
	contentVersionId: Id<ContentVersion>,
	templateId: Id<Template>,
	templateVersionId: Id<TemplateVersion>,
	eventJson: String,
}
