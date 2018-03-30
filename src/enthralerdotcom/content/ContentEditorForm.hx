package enthralerdotcom.content;

import smalluniverse.UniversalComponent;
import smalluniverse.SUMacro.jsx;
import enthraler.proptypes.PropTypes;

typedef ContentEditorFormProps<Content> = {
	content: Content,
	schema: PropTypes,
	onChange: Content -> Void
}

class ContentEditorForm<Content> extends UniversalComponent<ContentEditorFormProps<Content>, {}> {
	override public function render() {
		var fields = [for (name in props.schema.keys()) {
			var propType = props.schema.get(name);
			var type = propType.getEnum();
			var input = switch type {
				case PTArray(optional): jsx('<span>Array (multiple inputs)</span>');
				case PTBool(optional): jsx('<input type="checkbox" />');
				case PTNumber(optional): jsx('<input type="number" />');
				case PTInteger(optional): jsx('<input type="number" />');
				case PTObject(optional): jsx('<textarea></textarea>');
				case PTString(optional): jsx('<textarea></textarea>');
				case PTOneOf(values, optional): jsx('<select></select>');
				case PTOneOfType(types, optional): jsx('<span>TODO: one of type...</span>');
				case PTArrayOf(subType, optional): jsx('<span>TODO: Array (multiple inputs)</span>');
				case PTObjectOf(subType, optional): jsx('<span>TODO: Object (multiple inputs)</span>');
				case PTShape(shapedObject, optional): jsx('<span>TODO: Shape</span>');
				case PTAny(optional): jsx('<textarea></textarea>');
			};
			jsx('<div><label>${name}: ${input}</label></div>');
		}];
		return jsx('<div>
			<h2>FORM</h2>
			<div>${fields}</div>
		</div>');
	}
}