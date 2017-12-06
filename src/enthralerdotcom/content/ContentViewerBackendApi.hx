package enthralerdotcom.content;

import smalluniverse.*;
import enthralerdotcom.content.ContentViewerPage;
using tink.CoreApi;
import enthralerdotcom.content.Content;

class ContentViewerBackendApi implements BackendApi<ContentViewerAction, ContentViewerProps> {
	var guid: String;

	public function new(guid: String) {
		this.guid = guid;
	}

	public function get(context: SmallUniverseContext): Promise<ContentViewerProps> {
		var content = Content.manager.select($guid == this.guid);
		var latestVersion = ContentVersion.manager.select($contentID == content.id && $published != null, {orderBy: -published});
		if (latestVersion == null) {
			throw new Error(404, 'Content not found');
		}
		var templateVersion = latestVersion.templateVersion;
		var template = templateVersion.template;
		var embedUrl = 'https://enthraler.com/i/${this.guid}/embed';
		var embedCode = '<iframe src="${embedUrl}" className="enthraler-embed" frameBorder="0"></iframe>';
		var props:ContentViewerProps = {
			contentVersionId: latestVersion.id,
			templateName: template.name,
			templateUrl: templateVersion.mainUrl,
			contentUrl: '/i/${content.guid}/data/${latestVersion.id}',
			title: content.title,
			published: latestVersion.published,
			guid: content.guid,
			embedCode: embedCode
		};
		return props;
	}

	public function processAction(context: SmallUniverseContext, action: ContentViewerAction): Promise<BackendApiResult> {
		switch action {
			case _:
				return BackendApiResult.Done;
		}
	}
}
