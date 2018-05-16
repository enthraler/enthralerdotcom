package enthralerdotcom.components;

import smalluniverse.UniversalComponent;
import smalluniverse.SUMacro.jsx;

class AutoSizeTextArea extends UniversalComponent<{
	value: String,
	onChange: String->Void,
}, {}> {
	var textarea: js.html.TextAreaElement;

	override public function render() {
		function onChange(e) props.onChange(e.target.value);
		function setRef(ta) this.textarea = ta;
		return jsx('<textarea
			className="AutoSizeTextArea__textarea"
			ref=${setRef}
			value=${props.value}
			onChange=${onChange}>
		</textarea>');
	}

	override public function componentDidMount() {
		Webpack.require('./AutoSizeTextArea.scss');
		var autosize = Webpack.require('autosize');
		js.Browser.window.requestAnimationFrame(function (_) {
			autosize(textarea);
		});
	}
}
