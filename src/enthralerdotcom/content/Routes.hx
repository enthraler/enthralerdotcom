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

	@:get('/$guid/data/')
	@:get('/$guid/data/$id')
	public function getData(guid: String, ?id: Int) {
		return ContentServerRoutes.getDataJson(guid, id);
	}

	@:get('/$guid/embed/')
	@:get('/$guid/embed/$id')
	public function getEmbedFrame(guid: String, ?id: Int) {
		return ContentServerRoutes.redirectToEmbedFrame(guid, id);
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