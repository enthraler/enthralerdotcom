package enthralerdotcom.homepage;

import smalluniverse.*;
import enthralerdotcom.homepage.HomePage;
using tink.CoreApi;

class HomeBackendApi implements BackendApi<HomeAction, {}> {
	public function new() {
	}

	public function get(context: SmallUniverseContext):Promise<{}> {
		return {};
	}

	public function processAction(context: SmallUniverseContext, action:HomeAction):Promise<BackendApiResult> {
		switch action {
			case _:
				return BackendApiResult.Done;
		}
	}
}
