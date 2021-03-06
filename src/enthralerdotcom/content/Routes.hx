package enthralerdotcom.content;

import smalluniverse.*;
import dodrugs.Injector;
import enthralerdotcom.content.ContentEditorPage;
import enthralerdotcom.content.ContentViewerPage;
import enthralerdotcom.templates.TemplateVersion;
import enthralerdotcom.types.Url;
import enthralerdotcom.Db;
import tink.http.Response;
import tink.http.Header;
import tink.sql.OrderBy;
using tink.CoreApi;

class Routes {
	var injector: Injector<"enthralerdotcom">;
	var db: Db;
	var siteUrl: Url;
	var jsLibBaseUrl: Url;

	public function new(injector) {
		this.injector = injector;
		this.db = injector.get(Db);
		this.siteUrl = injector.get(var siteUrl: Url);
		this.jsLibBaseUrl = injector.get(var jsLibBaseUrl: Url);
	}

	@:all('/new/$templateId')
	public function newContent(templateId: Int, context: SmallUniverseContext) {
		return new SmallUniverse(function () {
			return injector.instantiateWith(ContentEditorPage, [
				templateId,
				var guid: String = null
			]);
		}, context);
	}

	@:get('/new/$templateId/embed/')
	public function newEmbed(templateId: Int) {
		return db.TemplateVersion
			.where(TemplateVersion.templateId == templateId)
			.first(TemplateVersionUtil.orderBySemver(db))
			.next(function (row) {
				var contentUrl = siteUrl + 'i/new/${templateId}/embed/blank.json',
					templateUrl = row.mainUrl,
					url = '$jsLibBaseUrl/frame.html#?template=$templateUrl&authorData=$contentUrl';
				return doHttpRedirect(url);
			});
	}

	@:get('/new/$templateId/embed/blank.json')
	public function newEmbedJson(templateId: Int) {
		return jsonResponseWithCors("{}");
	}

	@:all('/$guid/edit')
	public function editContent(guid: String, context: SmallUniverseContext) {
		return new SmallUniverse(function () {
			return injector.instantiateWith(ContentEditorPage, [
				guid,
				var templateId: Int = null
			]);
		}, context);
	}

	@:get('/$guid/data/')
	@:get('/$guid/data/$id')
	public function getData(guid: String, ?id: Int): Promise<OutgoingResponse> {
		return this.getVersion(guid, id).next(function (row) {
			if (row == null) {
				return new Error(404, 'Content version not found');
			}
			return jsonResponseWithCors(row.ContentVersion.jsonContent);
		});
	}

	@:get('/$guid/embed/')
	@:get('/$guid/embed/$id')
	public function getEmbedFrame(guid: String, ?id: Int): Promise<OutgoingResponse> {
		return this.getVersion(guid, id).next(function (row) {
			var contentUrl = siteUrl + 'i/${row.Content.guid}/data/${id != null ? '$id/' : ""}',
				templateUrl = row.TemplateVersion.mainUrl,
				url = '$jsLibBaseUrl/frame.html#?template=$templateUrl&authorData=$contentUrl';
			return doHttpRedirect(url);
		});
	}


	@:all('/$guid')
	public function viewContent(guid: String, context: SmallUniverseContext) {
		return new SmallUniverse(function () {
			return injector.instantiateWith(ContentViewerPage, [
				guid
			]);
		}, context);
	}

	function jsonResponseWithCors(jsonContent: String): OutgoingResponse {
		return new OutgoingResponse(
			new ResponseHeader(200, 200, [
				new HeaderField('Content-Type', 'application/json'),
				new HeaderField('Access-Control-Allow-Origin', jsLibBaseUrl.origin)
			]),
			jsonContent
		);
	}

	function getVersion(guid:String, id:Null<Int>) {
		var query = db.ContentVersion
			.join(db.TemplateVersion)
			.on(TemplateVersion.id == ContentVersion.templateVersionId)
			.join(db.Content)
			.on(Content.id == ContentVersion.contentId);
		query = (id != null)
			? query.where(ContentVersion.id == id)
			: query.where(Content.guid == guid && ContentVersion.published != null);
		if (id != null) {
			return query.where(ContentVersion.id == id).first();
		} else {
			return query
				.where(Content.guid == guid && ContentVersion.published != null)
				.first(function (_): OrderBy<Dynamic> {
					return [{
						field: db.ContentVersion.fields.published,
						order: Desc
					}];
				});
		}
	}

	static function header(status: Int, contentType: String) {
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