package enthralerdotcom.content;

import smalluniverse.*;
import enthralerdotcom.content.ContentEditorPage;
using tink.CoreApi;
#if server
import enthralerdotcom.types.*;
import enthralerdotcom.content.Content;
import enthralerdotcom.templates.TemplateVersion;
import enthralerdotcom.Db;
import tink.sql.OrderBy;
#end

class ContentEditorBackendApi implements BackendApi<ContentEditorAction, ContentEditorProps> {
	var guid: String;
	var db: Db;

	public function new(db: Db, guid: String) {
		this.db = db;
		this.guid = guid;
	}

	public function get(context: SmallUniverseContext):Promise<ContentEditorProps> {
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
			.next(function (result): Promise<ContentEditorProps> {
				if (result == null) {
					// TODO: If it is new content, with no version saved yet, create a new version.
					return new Error(404, 'Content Version not found');
				}
				var embedUrl = 'https://enthraler.com/i/${this.guid}/embed';
				var embedCode = '<iframe src="${embedUrl}" className="enthraler-embed" frameBorder="0"></iframe>';
				var c = result.Content,
					cv = result.ContentVersion,
					tv = result.TemplateVersion;
				var props:ContentEditorProps = {
					template:{
						name: tv.name,
						version: TemplateVersionUtil.getSemver(tv),
						versionId: tv.id,
						mainUrl: tv.mainUrl,
						schemaUrl: tv.schemaUrl
					},
					content:{
						id: c.id,
						title: cv.title,
						guid: c.guid,
					},
					currentVersion:{
						versionId: cv.id,
						jsonContent: cv.jsonContent,
						published: cv.published
					}
				};
				return props;
			});
	}

	public function processAction(context:SmallUniverseContext, action:ContentEditorAction):Promise<BackendApiResult> {
		switch action {
			case SaveAnonymousVersion(contentId, authorGuid, newContent, templateVersionId, draft):
				var ipAddress = new IpAddress(@:privateAccess context.request.clientIp);
				return saveAnonymousContentVersion(contentId, new UserGuid(authorGuid), ipAddress, newContent, templateVersionId, draft);
		}
	}

	public function saveAnonymousContentVersion(contentId:Int, authorGuid:UserGuid, authorIp:IpAddress, newContent:String, templateVersionId:Int, draft:Bool):Promise<BackendApiResult> {
		var contentVersion = ContentVersion.manager.select($contentID == contentId, {orderBy: -created});
		var author = AnonymousContentAuthor.manager.select(
			$contentID == contentId
			&& $guid == authorGuid
			&& $ipAddress == authorIp
			&& $modified > DateTools.delta(Date.now(), -24*60*60*1000)
		);
		if (contentVersion != null && author == null) {
			// This content already exists but is from a different author.  We should block this request.
			return Failure(new Error(tink.core.Error.ErrorCode.Forbidden, 'This content is no longer editable'));
		}

		if (contentVersion == null) {
			// This is the first entry - save the author so we can keep track of them going forward.
			author = new AnonymousContentAuthor().objectInit({
				contentID: contentId,
				guid: authorGuid,
				ipAddress: authorIp
			});
		}
		// Save the author - this will touch the "modified" field and give the user another 24 hours to keep editing.
		author.save();

		if (contentVersion == null || contentVersion.published != null) {
			// Either there was no previous version, or the previous version was already published - so save a new one.
			contentVersion = new ContentVersion();
		}

		contentVersion.objectInit({
			contentID: contentId,
			templateVersionID: templateVersionId,
			jsonContent: newContent,
			published: (draft) ? null : Date.now()
		});
		contentVersion.save();
		return BackendApiResult.Done;
	}
}
