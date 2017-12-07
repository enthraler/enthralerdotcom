package enthralerdotcom;

import smalluniverse.SmallUniverse;
import js.Browser.window;
import js.Browser.document;

// Import the pages we will need. They will be loaded via Reflection (for now).
import enthralerdotcom.templates.ManageTemplatesPage;
import enthralerdotcom.templates.ViewTemplatePage;
import enthralerdotcom.content.ContentEditorPage;

class Client {
	public static function main() {
		Webpack.require('./EnthralerStyles.scss');
		// Note: I'm having trouble getting this to import from HomePage.hx
		// So I'm importing it here temporarily.
		Webpack.require('./homepage/Mailchimp.css');
		onReady(function () {
			var propsElem = document.getElementById('small-universe-props');
			switch propsElem.getAttribute('data-page') {
				case 'enthralerdotcom.templates.ManageTemplatesPage':
					Webpack.load(ManageTemplatesPage).then(function () {
						SmallUniverse.hydrate(ManageTemplatesPage);
					});
				case 'enthralerdotcom.templates.ViewTemplatePage':
					Webpack.load(ViewTemplatePage).then(function () {
						SmallUniverse.hydrate(ViewTemplatePage);
					});
				case 'enthralerdotcom.content.ContentEditorPage':
					Webpack.load(ContentEditorPage).then(function () {
						SmallUniverse.hydrate(ContentEditorPage);
					});
				default: null;
			}
		});
	}

	static function onReady(fn:Void->Void) {
		if (document.readyState == "loading") {
			window.addEventListener("DOMContentLoaded", fn);
		} else {
			fn();
		}
	}
}
