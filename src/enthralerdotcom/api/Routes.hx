package enthralerdotcom.api;

import dodrugs.Injector;
import enthralerdotcom.Db;
import enthralerdotcom.types.Url;
import enthralerdotcom.types.ContentGuid;
import tink.http.Response;
import tink.http.Header;
using tink.CoreApi;
using StringTools;

class Routes {
	var injector: Injector<"enthralerdotcom">;
	var db: Db;

	public function new(injector) {
		this.injector = injector;
		this.db = injector.get(Db);
	}

	@:get('/oembed/')
	public function oembed(query: OEmbedRequest) {
		return OEmbed.process(query);
	}
}

class OEmbed {
	public static function process(request: OEmbedRequest): Promise<OutgoingResponse> {
		return processUrl(request.url)
			// TODO: we should do a database lookup and check if the item exists, get the title/author etc.
			.next(getOEmbedResponse.bind(request))
			.next(prepareOEmbedResponse.bind(request));
	}

	static function processUrl(url: Url): Promise<ContentId> {
		if (url.hostname != 'enthraler.com') {
			return new Error(404, 'The URL was not for enthraler.com');
		}
		var urlParts = url.uri.split('/');
		// Get rid of trailing slash
		if (urlParts[urlParts.length - 1] == "") {
			urlParts.pop();
		}
		return switch urlParts {
			case ['i', guid]: contentId(guid);
			case ['i', guid, 'embed']: contentId(guid);
			case ['i', guid, 'embed', id]: contentId(guid, id);
			case ['i', guid, 'edit']: contentId(guid);
			case ['i', guid, 'edit', id]: contentId(guid, id);
			default: new Error(404, 'The URL was not one that fits with our schema');
		}
	}

	static function contentId(guid, ?id) {
		return {
			guid: new ContentGuid(guid),
			id: Std.parseInt(id)
		}
	}

	static function getOEmbedResponse(request: OEmbedRequest, content: ContentId): OEmbedResponse {
		return {
			version: V1,
			type: rich,
			html: getIframeHtml(request, content),
			width: 100,
			height: 100,
			provider_name: 'Enthraler',
			provider_url: 'https://enthraler.com/',
		};
	}

	static function getIframeHtml(request: OEmbedRequest, content: ContentId): String {
		var url = 'https://enthraler.com/i/${content.guid}/embed';
		if (content.id != null) {
			url += '/${content.id}';
		}
		var style = "display: block;";
		if (request.maxWidth != null) {
			style += 'maxWidth: ${request.maxWidth}px; ';
		} else {
			style += 'maxWidth: 100%; ';
		}
		if (request.maxHeight != null) {
			style += 'maxHeight: ${request.maxHeight}px; ';
		}
		return '<iframe
			class="enthraler-embed"
			src="$url"
			sandbox="allow-same-origin allow-popups allow-presentation allow-scripts allow-forms"
			frameborder="0"
			style="$style">
		</iframe>'.replace('\t', ' ').replace('\n', ' ');
	}

	static function prepareOEmbedResponse(request: OEmbedRequest, oembedResponse: OEmbedResponse) {
		if (request.format == XML) {
			return new OutgoingResponse(
				header(200, 'text/xml'),
				renderXml(oembedResponse)
			);
		} else {
			return new OutgoingResponse(
				header(200, 'application/json'),
				tink.Json.stringify(oembedResponse)
			);
		}
	}

	static function renderXml(response: OEmbedResponse) {
		var props = [];
		for (field in Reflect.fields(response)) {
			var value = Reflect.field(response, field);
			if (value != null) {
				trace(field, value);
				props.push('<$field>${StringTools.htmlEscape(Std.string(value))}</$field>');
			}
		}
		return '<?xml version="1.0" encoding="utf-8" standalone="yes"?><oembed>${props.join('')}</oembed>';
	}

	static function header(status: Int, contentType: String) {
		return new ResponseHeader(status, status, [new HeaderField('Content-Type', contentType)]);
	}
}

typedef ContentId = {
	guid: ContentGuid,
	?id: Int
}

typedef OEmbedRequest = {
	url: String,
	?maxWidth: Int,
	?maxHeight: Int,
	?format: OEmbedFormat
}

@:enum abstract OEmbedFormat(String) from String {
	var JSON = "json";
	var XML = "xml";
}

typedef OEmbedResponse = {
	version: OEmbedVersion,
	type: OEmbedType,
	html: String,
	width: Int,
	height: Int,
	?title: String,
	?author_name: String,
	?author_url: Url,
	?provider_name: String,
	?provider_url: Url,
	?thumbnail_url: Url,
	?thumbnail_width: Int,
	?thumbnail_height: Int,
};

@:enum abstract OEmbedVersion(String) from String {
	var V1 = "1.0";
}

@:enum abstract OEmbedType(String) from String {
	var photo = "photo";
	var video = "video";
	var link = "link";
	var rich = "rich";
}