package enthralerdotcom.content;

import enthralerdotcom.content.ContentVersion;
import enthralerdotcom.types.*;
import tink.sql.Types;
using tink.CoreApi;

typedef ContentResource = {
	@:autoIncrement @:primary var id(default, null): Id<ContentResource>;
	var created(default, null): DateTime;
	var updated(default, null): DateTime;
	var contentVersionId(default, null): Id<ContentVersion>;
	var filePath(default, null): FilePath;
}

@:table(_join_ContentResource_ContentVersion)
typedef ContentResourceJoinContentVersion = {
	@:autoIncrement @:primary var id(default, null): Id<ContentResourceJoinContentVersion>;
	var contentResourceId(default, null): Id<ContentResource>;
	var contentVersionId(default, null): Id<ContentVersion>;
	var created(default, null): DateTime;
	var updated(default, null): DateTime;
}

class ContentResourceUtil {
	function getUrl(contentResource: ContentResource, s3BasePath:Url): Promise<Url> {
		var contentVersion = null;
		return new Url('${s3BasePath}${contentVersion.content.guid}/${contentVersion.id}/${contentResource.filePath}');
	}
}