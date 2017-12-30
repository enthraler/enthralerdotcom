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
			.join(db.Template)
			.on(TemplateVersion.templateId == Template.id)
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
					tv = result.TemplateVersion,
					tpl = result.Template;
				var props:ContentEditorProps = {
					template:{
						name: tpl.name,
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
				var newTitle = 'Untitled Enthraler';
				return saveAnonymousContentVersion(contentId, new UserGuid(authorGuid), ipAddress, newTitle, newContent, templateVersionId, draft);
		}
	}

	public function saveAnonymousContentVersion(contentId:Int, authorGuid:UserGuid, authorIp:IpAddress, newTitle:String, newContent:String, templateVersionId:Int, draft:Bool):Promise<BackendApiResult> {
		var contentVersionPromise = db.ContentVersion
			.where(ContentVersion.contentId == contentId)
			.first(function (_): OrderBy<Dynamic> {
				return [{
					field: db.ContentVersion.fields.created,
					order: Desc
				}];
			});
		var authorPromise = db.AnonymousContentAuthor
			.where(
				AnonymousContentAuthor.contentId == contentId
				&& AnonymousContentAuthor.guid == authorGuid
				&& AnonymousContentAuthor.ipAddress == authorIp
				&& AnonymousContentAuthor.updated > DateTools.delta(Date.now(), -24*60*60*1000)
			)
			.first();
		return contentVersionPromise
			.merge(authorPromise, function (c, a) return { contentVersion: c, author: a })
			.next(function (data) {
				var author = data.author,
					contentVersion = data.contentVersion;
				if (contentVersion != null && author == null) {
					// This content already exists but is from a different author.  We should block this request.
					return new Error(tink.core.Error.ErrorCode.Forbidden, 'This content is no longer editable');
				}
				if (contentVersion == null) {
					// This is the first entry - save the author so we can keep track of them going forward.
					author = {
						id: null,
						created: Date.now(),
						updated: Date.now(),
						contentId: contentId,
						guid: authorGuid,
						ipAddress: authorIp
					};
					return db.AnonymousContentAuthor
						.insertOne(author)
						.next(function (id) return new Pair(contentVersion, id));
				}
				// Renew the "updated" field so the author has another 24 hours to keep editing.
				return db.AnonymousContentAuthor
					.update(function (a) return [
						a.updated.set(Date.now())
					], {
						where: function (a) return a.id == author.id
					})
					.next(function (_) return new Pair(contentVersion, author.id));
			})
			.next(function (pair) {
				var existingVersion = pair.a,
					anonymousAuthorId = pair.b,
					publishedDate = (draft) ? null : Date.now();
				if (existingVersion == null || existingVersion.published != null) {
					// Either there was no previous version, or the previous version was already published - so save a new one.
					var contentVersion: ContentVersion = {
						id: null,
						created: Date.now(),
						updated: Date.now(),
						contentId: contentId,
						templateVersionId: templateVersionId,
						title: newTitle,
						jsonContent: newContent,
						published: publishedDate,
						anonymousAuthorId: anonymousAuthorId
					};
					return db.ContentVersion
						.insertOne(contentVersion)
						.next(function (id) return Noise);
				} else {
					// We have an existing draft, just update that version.
					return db.ContentVersion
						.update(function (cv) return [
							cv.updated.set(Date.now()),
							// Commenting out as we currently don't have a mechanism to update, and tink_sql is giving errors I can't be bothered investigating.
							// cv.templateVersionId.set(templateVersionId),
							cv.title.set(newTitle),
							cv.jsonContent.set(newContent),
							cv.published.set(publishedDate)
						], {
							where: function (cv) return cv.id == existingVersion.id
						})
						.next(function (_) return Noise);
				}
			})
			.next(function (_) return BackendApiResult.Done);
	}
}
