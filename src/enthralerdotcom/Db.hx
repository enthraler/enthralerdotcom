package enthralerdotcom;

import enthralerdotcom.content.AnonymousContentAuthor;
import enthralerdotcom.content.Content;
import enthralerdotcom.content.ContentVersion;
import enthralerdotcom.content.ContentResource;
import enthralerdotcom.content.ContentResourceJoinContentVersion;
import enthralerdotcom.contentanalytics.ContentAnalyticsEvent;
import enthralerdotcom.templates.Template;
import enthralerdotcom.templates.TemplateVersion;

@:tables(
	AnonymousContentAuthor,
	Content,
	ContentVersion,
	ContentResource,
	ContentResourceJoinContentVersion,
	ContentAnalyticsEvent,
	Template,
	TemplateVersion,
)
class Db extends tink.sql.Database {}