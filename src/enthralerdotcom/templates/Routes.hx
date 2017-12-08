package enthralerdotcom.templates;

import smalluniverse.*;
import dodrugs.Injector;

class Routes {
	var injector: Injector<"enthralerdotcom">;

	public function new(injector) {
		this.injector = injector;
	}

	@:all('/github/$username/$repo')
	public function viewTemplate(username: String, repo: String, context: SmallUniverseContext) {
		return new SmallUniverse(function () {
			return injector.instantiateWith(ViewTemplatePage, [
				username,
				repo,
			]);
		}, context);
	}


	@:all('/')
	public function manageTemplates(context: SmallUniverseContext) {
		return new SmallUniverse(function () {
			return injector.instantiate(ManageTemplatesPage);
		}, context);
	}
}