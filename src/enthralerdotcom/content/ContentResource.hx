package enthralerdotcom.content;

import enthralerdotcom.content.ContentVersion;
import enthralerdotcom.types.*;
import tink.sql.types.*;

typedef ContentResource = {
	id: Id<ContentResource>,
	created: DateTime,
	updated: DateTime,
	contentVersionId: Id<ContentVersion>,
}

typedef ContentResourceJoinContentVersion = {
	contentResourceId: Id<ContentResource>,
	contentVersionId: Id<ContentVersion>,
	created: DateTime,
	updated: DateTime,
}

class ContentResourceUtil {
	function getUrl(contentResource: ContentResource, s3BasePath:Url): Promise<Url> {
		var contentVersion = null;
		return new Url('${s3BasePath}${contentVersion.content.guid}/${contentVersion.id}/${contentResource.filePath}');
	}
}