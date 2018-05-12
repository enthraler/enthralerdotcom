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
			var value: Dynamic = Reflect.field(props.content, name);
			var type = props.schema.get(name).getEnum();
			var onChange = function (newVal: Dynamic) {
				// In JavaScript I would usually try clone props.content rather than modify it directly.
				// However I'm not sure the easiest way to treat objects as immutable in Haxe.
				Reflect.setField(props.content, name, newVal);
				props.onChange(props.content);
			};
			renderField(name, type, value, onChange);
		}];
		return jsx('<div>
			<h2>Form</h2>
			<div>${fields}</div>
		</div>');
	}

	static function renderField(name: String, type: PropTypeEnum, value: Dynamic, onChange: Dynamic->Void) {
		var input = switch type {
			case PTArray(optional): jsx('<span>Array (multiple inputs)</span>');
			case PTBool(optional): jsx('<Checkbox value=${value} onChange=${onChange} />');
			case PTNumber(optional): jsx('<IntInput value=${value} onChange=${onChange} />');
			case PTInteger(optional): jsx('<FloatInput value=${value} onChange=${onChange} />');
			case PTObject(optional): jsx('<textarea></textarea>');
			case PTString(optional): jsx('<TextInput value=${value} onChange=${onChange}></TextInput>');
			case PTOneOf(values, optional): jsx('<SelectInput options=${values} value=${value} onChange=${onChange}></SelectInput>');
			case PTOneOfType(types, optional): jsx('<span>TODO: one of type...</span>');
			case PTArrayOf(subType, optional): jsx('<span>TODO: Array (multiple inputs)</span>');
			case PTObjectOf(subType, optional): jsx('<span>TODO: Object (multiple inputs)</span>');
			case PTShape(shapedObject, optional): jsx('<ShapeForm name=${name} shape=${shapedObject} value=${value} onChange=${onChange} />');
			case PTAny(optional): jsx('<textarea></textarea>');
		};
		return jsx('<div key=${name}><label>${name}: ${input}</label></div>');
	}

	static function TextInput(props: {value: String, onChange: String->Void}) {
		var onChange = function (e) props.onChange(e.target.value);
		return jsx('<textarea value=${props.value} onChange=${onChange}></textarea>');
	}

	static function SelectInput(props: {options: Array<Dynamic>, value: Dynamic, onChange: Dynamic->Void}) {
		var options = [for (val in props.options) jsx('<option key=${val}>${val}</option>')];
		var onChange = function (e) props.onChange(e.target.value);
		return jsx('<select value=${props.value} onChange=${onChange}>
			${options}
		</select>');
	}

	static function Checkbox(props: {value: Bool, onChange: Bool->Void}) {
		var onChange = function (e) props.onChange(e.target.checked);
		return jsx('<input type="checkbox" checked=${props.value} onChange=${onChange} />');
	}

	static function IntInput(props: {value: Int, onChange: Int->Void}) {
		var onChange = function (e) props.onChange(Math.round(e.target.valueAsNumber ));
		return jsx('<input type="number" step={1} value=${props.value} onChange=${onChange} />');
	}

	static function FloatInput(props: {value: Float, onChange: Float->Void}) {
		var onChange = function (e) props.onChange(e.target.valueAsNumber);
		return jsx('<input type="number" step={1} value=${props.value} onChange=${onChange} />');
	}

	static function ShapeForm(props: {name: String, shape: Dynamic<PropTypeEnum>, value: Dynamic, onChange: Dynamic->Void}) {
		var shapeValue = props.value;
		var fields = [for (name in Reflect.fields(props.shape)) {
			var type = Reflect.field(props.shape, name);
			var fieldValue = Reflect.field(shapeValue, name);
			var onChange = function (newFieldVal: Dynamic) {
				Reflect.setField(shapeValue, name, newFieldVal);
				props.onChange(shapeValue);
			};
			renderField(name, type, fieldValue, onChange);
		}];
		return jsx('<div>
			<fieldset name=${props.name}>
				${fields}
			</fieldset>
		</div>');
	}
}