package enthralerdotcom.templates;

import tink.Json;
import enthralerdotcom.templates.ManageTemplatesPage;
import enthralerdotcom.templates.TemplateVersion;
import enthralerdotcom.templates.Template;
import haxe.Http;
import enthralerdotcom.types.*;
import enthralerdotcom.Db;
import enthraler.EnthralerPackageInfo;
import smalluniverse.*;
using tink.CoreApi;
#if server
using CleverSort;
#end

class ManageTemplatesBackendApi implements BackendApi<ManageTemplatesAction, ManageTemplatesPageProps> {
	var db: Db;

	public function new(db: Db) {
		this.db = db;
	}

	public function get(context):Promise<ManageTemplatesPageProps> {
		return db.TemplateVersion
			.join(db.Template)
			.on(TemplateVersion.templateId == Template.id)
			.all(null, TemplateVersionUtil.orderBySemver(db))
			.next(function (versions): ManageTemplatesPageProps {
				var allTemplates = new Map();
				for (row in versions) {
					var template = row.Template;
					var version = row.TemplateVersion;
					if (!allTemplates.exists(template.id)) {
						allTemplates[template.id] = {
							id: template.id,
							name: template.name,
							homepage: template.homepage,
							versions: []
						};
						allTemplates[template.id].versions.push({
							mainUrl: version.mainUrl,
							version: TemplateVersionUtil.getSemver(version)
						});
					}
				}
				var templatesArray = [for (tpl in allTemplates) tpl];
				templatesArray.cleverSort(_.name);
				return {
					templates: templatesArray
				};
			});
	}

	public function processAction(context, action:ManageTemplatesAction):Promise<BackendApiResult> {
		switch action {
			case AddGithubRepoAsTemplate(githubUser, githubRepo):
				return pullTemplateFromGithubRepo(githubUser, githubRepo);
			case ReloadTemplate(id):
				return reloadTemplate(id);
		}
	}

	public function pullTemplateFromGithubRepo(githubUser:String, githubRepo:String, ?tpl:Template):Promise<BackendApiResult> {
		if (tpl == null) {
			tpl = new Template();
		}
		return getGithubInfo(githubUser, githubRepo)
			.next(function (data) {
				tpl.name = '$githubUser/$githubRepo';
				tpl.description = data.description;
				tpl.homepage = new Url(data.html_url);
				tpl.source = TemplateSource.Github(githubUser, githubRepo);
				tpl.save();
				return getGithubTags(githubUser, githubRepo);
			})
			.next(function (tags) {
				var tagFutures = [];
				for (tag in tags) {
					// Create a TemplateVersion
					tagFutures.push(saveVersionInfo(githubUser, githubRepo, tpl, tag));
				}
				return Future.ofMany(tagFutures).map(function (_) return BackendApiResult.Done);
			});
	}

	function getGithubInfo(githubUser:String, githubRepo:String):Promise<{name:String, description:String, html_url:String}> {
		var url = 'https://api.github.com/repos/$githubUser/$githubRepo';
		return loadUrl(url).next(function (resp):{name:String, description:String, html_url:String} {
			return Json.parse(resp);
		});
	}

	function getGithubTags(githubUser:String, githubRepo:String):Promise<Array<String>> {
		var url = 'https://api.github.com/repos/$githubUser/$githubRepo/git/refs/tags';
		return loadUrl(url).next(function (resp):Array<String> {
			var data:Array<{ref:String}> = Json.parse(resp);
			var tags = [];
			for (obj in data) {
				var tag = obj.ref.split('/').pop();
				if (~/^[0-9]+\.[0-9]+\.[0-9]$/.match(tag)) {
					tags.push(tag);
				}
			}
			return tags;
		});
	}

	function saveVersionInfo(githubUser:String, githubRepo:String, tpl:Template, tag:String) {
		var parts = tag.split("."),
			major = Std.parseInt(parts[0]),
			minor = Std.parseInt(parts[1]),
			patch = Std.parseInt(parts[2]),
			version = TemplateVersion.manager.select(
				$templateID == tpl.id
				&& $major==major
				&& $minor==minor
				&& $patch==patch
			);
		if (version == null) {
			version = new TemplateVersion();
			version.major = major;
			version.minor = minor;
			version.patch = patch;
			version.template = tpl;
			version.basePath = new Url('https://cdn.rawgit.com/$githubUser/$githubRepo/$tag/');
		}
		return
			loadUrl(version.basePath + 'package.json')
				.next(function (resp) {
					var data:{enthraler:EnthralerPackageInfo} = Json.parse(resp);
					version.mainUrl = new Url(version.basePath + data.enthraler.main);
					version.schemaUrl = new Url(version.basePath + data.enthraler.schema);
					return loadUrl(version.basePath + 'README.md')
						.recover(function (err:Error) return "")
						.next(function (readmeStr:String):Noise {
							version.readme = (readmeStr!="") ? readmeStr : null;
							return Noise;
						});
				})
				.next(function (_):BackendApiResult {
					version.save();
					return BackendApiResult.Done;
				});
	}

	function loadUrl(url:String):Promise<String> {
		return Future.async(function (cb) {
			// Tech debt: at time of writing, haxe.Http has an odd PHP implementation that is throwing EOF.
			// Probably this error: https://github.com/HaxeFoundation/haxe/issues/6244
			// Let's use CURL instead!

			var curl = untyped __call__("curl_init");
			untyped __call__("curl_setopt", curl, untyped __php__('CURLOPT_URL'), url);
			untyped __call__("curl_setopt", curl, untyped __php__('CURLOPT_RETURNTRANSFER'), true);
			untyped __call__("curl_setopt", curl, untyped __php__('CURLOPT_USERAGENT'), 'enthraler');
			var resp:Dynamic = untyped __call__("curl_exec", curl);

			var httpStatus:Int = untyped __call__("curl_getinfo", curl, untyped __php__('CURLINFO_HTTP_CODE'));
			if (httpStatus == 200) {
				var responseText:String = resp;
				cb(Success(responseText));
			} else {
				var error:String = untyped __call__("curl_error", curl);
				cb(Failure(new Error('Failed to load $url: $error. $resp')));
			}

			untyped __call__("curl_close", curl);
		});
	}

	public function reloadTemplate(id:Int):Promise<BackendApiResult> {
		var tpl = Template.manager.get(id);
		switch tpl.source {
			case Github(username, repo):
				return pullTemplateFromGithubRepo(username, repo, tpl);
		}
	}
}
