package enthralerdotcom.templates;

import tink.Json;
import enthralerdotcom.templates.ManageTemplatesPage;
using tink.CoreApi;
import enthralerdotcom.types.*;
import enthraler.EnthralerPackageInfo;
import smalluniverse.*;

class ManageTemplatesBackendApi implements BackendApi<ManageTemplatesAction, ManageTemplatesPageProps> {
	public function new() {

	}

	public function get(context):Promise<ManageTemplatesPageProps> {
		var allTemplates = Template.manager.all();
		var templates = [];
		for (tpl in allTemplates) {
			templates.push({
				id: tpl.id,
				name: tpl.name,
				homepage: tpl.homepage,
				versions: [for (v in tpl.versions) {
					mainUrl: v.mainUrl,
					version: v.getSemver()
				}]
			});
		}
		return {
			templates: templates
		};
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
