package enthralerdotcom.templates;

import smalluniverse.*;
import enthralerdotcom.templates.ViewTemplatePage;
using tink.CoreApi;
#if server
import enthralerdotcom.content.Content;
using ObjectInit;
#end

class ViewTemplateBackendApi implements BackendApi<ViewTemplateAction, ViewTemplateProps> {
	var username: String;
	var repo: String;

	public function new(username: String, repo: String) {
		this.username = username;
		this.repo = repo;
	}

	function getTemplateName() {
		return '$username/$repo';
	}

	function getTemplate() {
		var name = getTemplateName();
		return Template.manager.select($name == name);
	}

	public function get(context: SmallUniverseContext):Promise<ViewTemplateProps> {
		var tpl = getTemplate();
		var versions = TemplateVersion.manager.search($templateID==tpl.id, {
			orderBy: [-major, -minor, -patch]
		});
		var latestVersion = versions.first();
		var props:ViewTemplateProps = {
			template: {
				name: tpl.name,
				description: tpl.description,
				homepage: tpl.homepage,
				readme: Markdown.markdownToHtml(latestVersion.readme),
				versions: [for (v in versions) {
					version: v.getSemver(),
					mainUrl: v.mainUrl
				}]
			}
		};
		return props;
	}

	public function processAction(context: SmallUniverseContext, action: ViewTemplateAction):Promise<BackendApiResult> {
		switch action {
			case CreateNewContent:
				var tpl = getTemplate();
				var version = TemplateVersion.manager.select($templateID==tpl.id, {
					orderBy: [-major, -minor, -patch]
				});
				var content = new Content().init({
					title: 'My new enthraler',
					template: tpl,
				});
				content.save();
				trace('Creating content ${content.id}, ${content.guid}');
				return BackendApiResult.Redirect('/i/${content.guid}/edit/');
		}
	}
}
