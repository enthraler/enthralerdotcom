package enthralerdotcom.templates;

import smalluniverse.*;
import enthralerdotcom.templates.ViewTemplatePage;
import enthralerdotcom.Db;
using tink.CoreApi;
#if server
import enthralerdotcom.content.Content;
import enthralerdotcom.templates.Template;
import enthralerdotcom.templates.TemplateVersion;
import enthralerdotcom.types.ContentGuid;
import tink.Json;
using ObjectInit;
#end

class ViewTemplateBackendApi implements BackendApi<ViewTemplateAction, ViewTemplateProps> {
	var db: Db;
	var username: String;
	var repo: String;

	public function new(db: Db, username: String, repo: String) {
		this.db = db;
		this.username = username;
		this.repo = repo;
	}

	public function get(context: SmallUniverseContext):Promise<ViewTemplateProps> {
		return getTemplate()
			.next(function (tpl: Template) {
				return getVersions(tpl.id).next(function (versions) {
					return {
						tpl: tpl,
						versions: versions,
						latestVersion: versions[0]
					};
				});
			})
			.next(function (data): ViewTemplateProps {
				// Note, we're using `readme.toString()` because tink_sql is incorrectly returning a StringBuf not a String
				var readme = data.latestVersion.readme != null ? Markdown.markdownToHtml(data.latestVersion.readme.toString()) : "";
				return {
					template: {
						id: data.tpl.id,
						name: data.tpl.name,
						description: data.tpl.description,
						homepage: data.tpl.homepage,
						readme: readme,
						versions: [for (v in data.versions) {
							version: TemplateVersionUtil.getSemver(v),
							mainUrl: v.mainUrl
						}]
					}
				};
			});
	}

	function getTemplate(): Promise<Template> {
		var sourceJson = Json.stringify(Github(username, repo));
		return db.Template.where(Template.sourceJson == sourceJson).first();
	}

	function getVersions(templateId: Int): Promise<Array<TemplateVersion>> {
		return db.TemplateVersion
			.where(TemplateVersion.templateId == templateId)
			.all(null, TemplateVersionUtil.orderBySemver(db));
	}

	public function processAction(context: SmallUniverseContext, action: ViewTemplateAction):Promise<BackendApiResult> {
		return BackendApiResult.Done;
	}
}
