package enthralerdotcom.content;

import tink.http.Response;
import tink.http.Header;
using tink.CoreApi;

/**
A collection of functions used for handling server routes that are not React pages - eg embed frames or JSON data.
**/
class ContentServerRoutes {
	public static function getDataJson(guid: String, ?id: Int): Promise<OutgoingResponse> {
		var version = getVersion(guid, id);
		if (version == null) {
			return new Error(404, 'Content version not found');
		}
		return new OutgoingResponse(
			header(200, 'application/json'),
			version.jsonContent
		);
	}

	public static function redirectToEmbedFrame(guid: String, ?id: Int): Promise<OutgoingResponse> {
		var baseUrl = '/jslib/0.1.1';
		var version = getVersion(guid, id);
		var contentUrl = '/i/${guid}/data/${version.id}';
		var templateUrl = version.templateVersion.mainUrl;
		var url = '$baseUrl/frame.html#?template=${templateUrl}&authorData=${contentUrl}';
		return doHttpRedirect(url);
	}

	static function getVersion(guid:String, id:Null<Int>):ContentVersion {
		if (id != null) {
			return ContentVersion.manager.get(id);
		}
		var content = Content.manager.select($guid == guid);
		return ContentVersion.manager.select($contentID == content.id && $published != null, {
			orderBy: -published,
			limit: 1
		});
	}

	static inline function header(status: Int, contentType: String) {
		return new ResponseHeader(status, status, [new HeaderField('Content-Type', contentType)]);
	}

	static function doHttpRedirect(url: String): OutgoingResponse {
		return new OutgoingResponse(
			new ResponseHeader(TemporaryRedirect, 307, [
				new HeaderField('Location', url)
			]),
			""
		);
	}
}
