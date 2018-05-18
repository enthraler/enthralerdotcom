package enthralerdotcom.components;

import smalluniverse.UniversalComponent;
import smalluniverse.SUMacro.jsx;

typedef IconButtonProps = {
	children: smalluniverse.UniversalNode,
	onClick: Void->Void,
	text: String,
}

class IconButton extends UniversalComponent<IconButtonProps, {}> {
	override public function render() {
		return jsx('<button className="IconButton__btn" onClick=${props.onClick} title=${props.text}>
			${props.children}
			<span className="IconButton__srOnly">${props.text}</span>
		</button>');
	}

	override public function componentDidMount() {
		Webpack.require('./IconButton.scss');
	}
}
