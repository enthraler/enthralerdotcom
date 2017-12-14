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
	var id(default, null): Id<AnonymousContentAuthor>;
	var created(default, null): DateTime;
	var updated(default, null): DateTime;
	var contentId(default, null): Id<Content>;
	var guid(default, null): UserGuid;
	var ipAddress(default, null): IpAddress;
}
