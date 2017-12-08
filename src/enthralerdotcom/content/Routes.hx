package enthralerdotcom.content;

import smalluniverse.*;
import dodrugs.Injector;

class Routes {
	var injector: Injector<"enthralerdotcom">;

	public function new(injector) {
		this.injector = injector;
	}

	@:all('/$guid/edit')
	public function editContent(guid: String, context: SmallUniverseContext) {
		return new SmallUniverse(function () {
			return injector.instantiateWith(enthralerdotcom.content.ContentEditorPage, [
				guid
			]);
		}, context);
	}


	@:all('/$guid')
	public function viewContent(guid: String, context: SmallUniverseContext) {
		return new SmallUniverse(function () {
			return injector.instantiateWith(enthralerdotcom.content.ContentViewerPage, [
				guid
			]);
		}, context);
	}
}