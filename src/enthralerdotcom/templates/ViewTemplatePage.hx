package enthralerdotcom.templates;

import smalluniverse.UniversalPage;
import smalluniverse.SUMacro.jsx;
import enthralerdotcom.components.*;
#if client
	import js.html.*;
#end
using tink.CoreApi;

enum ViewTemplateAction {
	CreateNewContent;
}
typedef ViewTemplateParams = {user:String, repo:String};
typedef ViewTemplateProps = {
	template:{
		name:String,
		description:String,
		homepage:String,
		readme:String,
		versions:Array<{
			mainUrl:String,
			version:String
		}>,
	}
};

class ViewTemplatePage extends UniversalPage<ViewTemplateAction, ViewTemplateProps, {}> {

	@:client var githubUsername:String;
	@:client var githubRepo:String;

	public function new(templatesApi:ViewTemplateBackendApi) {
		super(templatesApi);
	}

	override function render() {
		Head.prepareHead(this.head);
		this.head.setTitle('Manage templates!');
		var tpl = this.props.template;
		var versionListItems = [for (v in tpl.versions) jsx('<li>${v.version.toString()}</li>')];
		return jsx('<div className="container">
			<HeaderNav></HeaderNav>
			<h1 className="title">${tpl.name}</h1>
			<h2 className="subtitle">${tpl.description}</h2>
			<a onClick=${createNewContent} className="button is-primary is-large">
				Make your own
			</a>
			<h3 className="subtitle"><a href=${tpl.homepage} target="_BLANK">${tpl.homepage}</a></h3>
			<article className="message is-info">
				<div className="message-header">
					<p>README</p>
				</div>
				<Markdown html=${tpl.readme} className="message-body content"></Markdown>
			</article>
			<div className="content">
				<h3>Versions</h3>
				<ul>
					${versionListItems}
				</ul>
			</div>
		</div>');
	}

	@:client
	function createNewContent() {
		this.trigger(CreateNewContent);
	}
}
