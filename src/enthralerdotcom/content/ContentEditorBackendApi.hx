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
	var db: Db;
	var contentGuidOrTemplateId: Either<String, Int>;

	public function new(db: Db, guid: String, templateId: Int) {
		this.db = db;
		this.contentGuidOrTemplateId = (guid != null) ? Left(guid) : Right(templateId);
	}

	public function get(context: SmallUniverseContext): Promise<ContentEditorProps> {
		switch contentGuidOrTemplateId {
			case Left(guid):
				return getExisting(guid);
			case Right(templateId):
				return getNew(templateId);
		}
	}

	public function getExisting(guid: String): Promise<ContentEditorProps> {
		return db.Content
			.join(db.Template)
			.on(Content.templateId == Template.id)
			.join(db.ContentVersion)
			.on(ContentVersion.contentId == Content.id)
			.join(db.TemplateVersion)
			.on(TemplateVersion.id == ContentVersion.templateVersionId)
			.where(Content.guid == guid)
			.first(function (_): OrderBy<Dynamic> {
				return [{
					field: db.ContentVersion.fields.published,
					order: Desc
				}];
			})
			.next(function (result): Promise<ContentEditorProps> {
				var c = result.Content,
					cv = result.ContentVersion,
					tv = result.TemplateVersion,
					tpl = result.Template;
				var props:ContentEditorProps = {
					template:{
						id: tpl.id,
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

	public function getNew(templateId: Int): Promise<ContentEditorProps> {
		return db.TemplateVersion
			.join(db.Template)
			.on(Template.id == TemplateVersion.templateId)
			.where(TemplateVersion.templateId == templateId)
			.first(TemplateVersionUtil.orderBySemver(db))
			.next(function (row): Promise<ContentEditorProps> {
				var tpl = row.Template;
				var tv = row.TemplateVersion;
				var props:ContentEditorProps = {
					template:{
						id: tpl.id,
						name: tpl.name,
						version: TemplateVersionUtil.getSemver(tv),
						versionId: tv.id,
						mainUrl: tv.mainUrl,
						schemaUrl: tv.schemaUrl
					},
					content:{
						id: null,
						title: 'Untitled Enthraler',
						guid: null,
					},
					currentVersion:{
						versionId: null,
						jsonContent: '{}',
						published: null
					}
				};
				return props;
			});
	}

	public function processAction(context:SmallUniverseContext, action:ContentEditorAction):Promise<BackendApiResult> {
		var ipAddress = new IpAddress(@:privateAccess context.request.clientIp);
		var newTitle = 'Untitled Enthraler';
		trace('process action', action);
		switch action {
			case SaveFirstAnonymousVersion(authorGuid, newContent, templateId, templateVersionId, draft):
				trace('save first');
				var content: Content = {
					id: null,
					created: Date.now(),
					updated: Date.now(),
					guid: ContentGuid.generate(),
					copiedFromId: null,
					templateId: templateId
				};
				return db.Content
					.insertOne(content)
					.next(function (contentId: Int) {
						trace('Creating content ${contentId}, ${content.guid}');
						return saveAnonymousContentVersion(contentId, new UserGuid(authorGuid), ipAddress, newTitle, newContent, templateVersionId, draft);
					})
					.next(function (result) {
						return BackendApiResult.Redirect('/i/${content.guid}/edit/');
					});
			case SaveAnonymousVersion(contentId, authorGuid, newContent, templateVersionId, draft):
				return saveAnonymousContentVersion(contentId, new UserGuid(authorGuid), ipAddress, newTitle, newContent, templateVersionId, draft);
		}
	}

	public function saveAnonymousContentVersion(contentId:Int, authorGuid:UserGuid, authorIp:IpAddress, newTitle:String, newContent:String, templateVersionId:Int, draft:Bool):Promise<BackendApiResult> {
		var contentVersionPromise = db.ContentVersion
			.where(ContentVersion.contentId == contentId)
			.all(function (_): OrderBy<Dynamic> {
				return [{
					field: db.ContentVersion.fields.created,
					order: Desc
				}];
			})
			.next(function (versions) {
				// Annoyingly, tink_sql can't do first() if the result is null, it will 404 rather than return nulll.
				// So get all of them, and pick the first.
				return versions[0];
			});
		var authorPromise = db.AnonymousContentAuthor
			.where(
				AnonymousContentAuthor.contentId == contentId
				&& AnonymousContentAuthor.guid == authorGuid
				&& AnonymousContentAuthor.ipAddress == authorIp
				&& AnonymousContentAuthor.updated > DateTools.delta(Date.now(), -24*60*60*1000)
			)
			.all()
			.next(function (authors) {
				// Annoyingly, tink_sql can't do first() if the result is null, it will 404 rather than return nulll.
				// So get all of them, and pick the first.
				return authors[0];
			});
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
