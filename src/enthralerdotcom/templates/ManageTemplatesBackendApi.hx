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
		return getGithubInfo(githubUser, githubRepo)
			.next(function (data) {
				var name = '$githubUser/$githubRepo',
					description = data.description,
					homepage = new Url(data.html_url),
					sourceJson = Json.stringify(TemplateSource.Github(githubUser, githubRepo));
				if (tpl == null) {
					tpl = {
						id: null,
						created: Date.now(),
						updated: Date.now(),
						name: name,
						description: description,
						homepage: homepage,
						sourceJson: sourceJson
					};
					return db.Template
						.insertOne(tpl)
						.next(function (id) {
							// These read-only types are getting annyoing. Need a macro helper.
							tpl = {
								id: id,
								created: tpl.created,
								updated: tpl.updated,
								name: tpl.name,
								description: tpl.description,
								homepage: tpl.homepage,
								sourceJson: tpl.sourceJson,
							};
							return Noise;
						});
				} else {
					return db.Template
						.update(function (t) return [
							t.updated.set(Date.now()),
							t.name.set(name),
							t.description.set(description),
							t.homepage.set(homepage),
							t.sourceJson.set(sourceJson)
						], {
							where: function (t) return t.id == tpl.id
						})
						.next(function (_) return Noise);
				}
			})
			.next(function (_) {
				return getGithubTags(githubUser, githubRepo);
			})
			.next(function (tags) {
				var tagFutures = [];
				for (tag in tags) {
					// Create a TemplateVersion
					tagFutures.push(saveVersionInfo(githubUser, githubRepo, tpl, tag));
				}
				return Future.ofMany(tagFutures).map(function (results): Outcome<BackendApiResult, Error> {
					for (outcome in results) {
						switch outcome {
							case Success(_):
							case Failure(err):
								return Failure(new Error(err.code, 'Error saving template version: ${err.message}', err.pos));
						}
					}
					return Success(BackendApiResult.Done);
				});
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
			baseUrl = new Url('https://cdn.rawgit.com/$githubUser/$githubRepo/$tag/'),
			existingVersion: TemplateVersion = null,
			packageInfo: {
				var name: String;
				@:optional var description: String;
				@:optional var homepage: String;
				var enthraler: EnthralerPackageInfo;
			} = null,
			mainUrl = null,
			schemaUrl = null;
		return db.TemplateVersion
			.where(
				TemplateVersion.templateId == tpl.id
				&& TemplateVersion.major == major
				&& TemplateVersion.minor == minor
				&& TemplateVersion.patch == patch
			)
			.all()
			.next(function (versions) {
				var version = versions[0];
				existingVersion = version;
				return loadUrl(baseUrl + 'package.json');

			})
			.next(function (resp) {
				packageInfo = Json.parse(resp);
				mainUrl = new Url(baseUrl + packageInfo.enthraler.main);
				schemaUrl = new Url(baseUrl + packageInfo.enthraler.schema);
				return loadUrl(baseUrl + 'README.md').recover(function (err:Error) return "");
			})
			.next(function (readme:String) {
				if (readme == "") {
					readme = null;
				}
				if (existingVersion == null) {
					var version = {
						id: null,
						created: Date.now(),
						updated: Date.now(),
						templateId: tpl.id,
						major: major,
						minor: minor,
						patch: patch,
						baseUrl: baseUrl,
						mainUrl: mainUrl,
						schemaUrl: schemaUrl,
						readme: readme,
					};
					return db.TemplateVersion.insertOne(version).next(function (id) return Noise);
				} else {
					return db.TemplateVersion.update(function (tv) {
						return [
							tv.updated.set(Date.now()),
							tv.mainUrl.set(mainUrl),
							tv.schemaUrl.set(schemaUrl),
							tv.readme.set(readme),
						];
					}, {
						where: function (tv) return tv.id == existingVersion.id
					})
					.next(function (_) return Noise);
				}
				return Noise;
			});
	}

	function loadUrl(url:String):Promise<String> {
		return Future.async(function (cb) {
			var http = new Http(url);
			var status = null;
			http.onStatus = function (s) status = s;
			http.onData = function (data) cb(Success(data));
			http.onError = function (err) cb(Failure(new Error(status, http.responseData)));
			http.addHeader('User-Agent', 'enthraler.com API');
			http.request();
		});
	}

	public function reloadTemplate(id:Int):Promise<BackendApiResult> {
		return db.Template.where(Template.id == id).all().next(function (templates) {
			var tpl = templates[0];
			var source: TemplateSource = Json.parse(tpl.sourceJson);
			switch source {
				case Github(username, repo):
					return pullTemplateFromGithubRepo(username, repo, tpl);
			}
		});
	}
}
