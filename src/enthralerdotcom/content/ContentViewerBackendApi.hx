package enthralerdotcom.content;

import smalluniverse.*;
import enthralerdotcom.content.ContentViewerPage;
import enthralerdotcom.content.Content;
import enthralerdotcom.templates.*;
import enthralerdotcom.Db;
import tink.sql.OrderBy;
using tink.CoreApi;

class ContentViewerBackendApi implements BackendApi<ContentViewerAction, ContentViewerProps> {
	var db: Db;
	var guid: String;

	public function new(db: Db, guid: String) {
		this.db = db;
		this.guid = guid;
	}

	public function get(context: SmallUniverseContext): Promise<ContentViewerProps> {
		return db.Content
			.join(db.ContentVersion)
			.on(ContentVersion.contentId == Content.id)
			.join(db.TemplateVersion)
			.on(TemplateVersion.id == ContentVersion.templateVersionId)
			.where(Content.guid == this.guid && ContentVersion.published != null)
			.first(function (_): OrderBy<Dynamic> {
				return [{
					field: db.ContentVersion.fields.published,
					order: Desc
				}];
			})
			.next(function (result): Promise<ContentViewerProps> {
				if (result == null) {
					return new Error(404, 'Content not found');
				}
				var embedUrl = 'https://enthraler.com/i/${this.guid}/embed';
				var embedCode = '<iframe src="${embedUrl}" className="enthraler-embed" frameBorder="0"></iframe>';
				var props:ContentViewerProps = {
					contentVersionId: result.ContentVersion.id,
					templateName: result.TemplateVersion.name,
					templateUrl: result.TemplateVersion.mainUrl,
					contentUrl: '/i/${result.Content.guid}/data/${result.ContentVersion.id}',
					title: result.ContentVersion.title,
					published: result.ContentVersion.published,
					guid: result.Content.guid,
					embedCode: embedCode
				};
				return props;
			});
	}

	public function processAction(context: SmallUniverseContext, action: ContentViewerAction): Promise<BackendApiResult> {
		switch action {
			case _:
				return BackendApiResult.Done;
		}
	}
}
