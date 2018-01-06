package enthralerdotcom.contentanalytics;

import enthralerdotcom.types.*;
import sys.db.Types;

enum ContentAnalyticsEventType {
	ContentLoaded(userGuid:UserGuid, referrer:Url, ip:IpAddress);
	ContentInView(userGuid:UserGuid);
	ContentInteracted(userGuid:UserGuid);
}
