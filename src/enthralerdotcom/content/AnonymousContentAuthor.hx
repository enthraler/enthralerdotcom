package enthralerdotcom.content;

import enthralerdotcom.types.*;
import tink.sql.types.*;

/**
When an unauthenticated user creates an enthraler, we only allow them to edit it while the tab is open.
We use a unique GUID, their IP address, and a timestamp to authenticate that the same user who created it is the one updating it.
**/
// @:index(contentId, unique)
// @:index(contentID, guid)
// @:index(guid)
typedef AnonymousContentAuthor = {
	id: Id<AnonymousContentAuthor>,
	created: DateTime,
	updated: DateTime,
	contentId: Id<Content>,
	guid: UserGuid,
	ipAddress: IpAddress,
}
