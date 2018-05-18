package enthralerdotcom.content;

import smalluniverse.UniversalComponent;
import smalluniverse.SUMacro.jsx;
import enthraler.proptypes.PropTypes;
import enthralerdotcom.components.IconButton;
import enthralerdotcom.components.AutoSizeTextArea;

typedef ContentEditorFormProps<Content> = {
	content: Content,
	schema: PropTypes,
	onChange: Content -> Void
}

class ContentEditorForm<Content> extends UniversalComponent<ContentEditorFormProps<Content>, {}> {
	override public function componentDidMount() {
		Webpack.require('./ContentEditorForm.scss');
	}

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
			${fields}
		</div>');
	}

	public static function renderField(name: String, type: PropTypeEnum, value: Dynamic, onChange: Dynamic->Void, ?hideLabel = false) {
		function withLabel(input) {
			if (hideLabel) {
				return input;
			}
			return jsx('<div key=${name} className="ContentEditorForm__labelContainer">
				<label className="ContentEditorForm__label">${name}:</label>
				<span className="ContentEditorForm__field">${input}</span>
			</div>');
		}
		return switch type {
			case PTArray(optional): jsx('<ArrayForm name=${name} subType=${PTAny(true)} value=${value} onChange=${onChange} />');
			case PTBool(optional): withLabel(jsx('<Checkbox value=${value} onChange=${onChange} />'));
			case PTNumber(optional): withLabel(jsx('<IntInput value=${value} onChange=${onChange} />'));
			case PTInteger(optional): withLabel(jsx('<FloatInput value=${value} onChange=${onChange} />'));
			case PTObject(optional): jsx('<ObjectForm name=${name} subType=${PTAny(true)} value=${value} onChange=${onChange} />');
			case PTString(optional): withLabel(jsx('<TextInput value=${value} onChange=${onChange}></TextInput>'));
			case PTOneOf(values, optional): withLabel(jsx('<SelectInput options=${values} value=${value} onChange=${onChange}></SelectInput>'));
			case PTOneOfType(types, optional): jsx('<OneOfTypeForm name=${name} types=${types} value=${value} onChange=${onChange} />');
			case PTArrayOf(subType, optional): jsx('<ArrayForm name=${name} subType=${subType} value=${value} onChange=${onChange} />');
			case PTObjectOf(subType, optional): jsx('<ObjectForm name=${name} subType=${subType} value=${value} onChange=${onChange} />');
			case PTShape(shapedObject, optional): jsx('<ShapeForm name=${name} shape=${shapedObject} value=${value} onChange=${onChange} />');
			case PTAny(optional): jsx('<OneOfTypeForm name=${name} types=${[
				PTString(true),
				PTNumber(true),
				PTInteger(true),
				PTBool(true),
				PTArray(true),
				PTObject(true),
			]} value=${value} onChange=${onChange} />');
		};
	}

	static function getDefaultValue(type: PropTypeEnum): Dynamic {
		return switch type {
			case PTArray(optional): [];
			case PTBool(optional): false;
			case PTNumber(optional): 0.0;
			case PTInteger(optional): 0;
			case PTObject(optional): {};
			case PTString(optional): '';
			case PTOneOf(values, optional): values[0];
			case PTOneOfType(types, optional): getDefaultValue(types[0]);
			case PTArrayOf(subType, optional): [getDefaultValue(subType)];
			case PTObjectOf(subType, optional): {};
			case PTShape(shapedObject, optional):
				var obj = {};
				for (name in Reflect.fields(shapedObject)) {
					var type = Reflect.field(shapedObject, name);
					Reflect.setField(obj, name, getDefaultValue(type));
				}
				obj;
			case PTAny(optional): '';
		};
	}

	static function TextInput(props: {value: String, onChange: String->Void}) {
		return jsx('<AutoSizeTextArea value=${props.value} onChange=${props.onChange}></AutoSizeTextArea>');
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
		return jsx('<div className="ContentEditorForm__section">
			<h3 class="ContentEditorForm__h3">${props.name}</h3>
			${fields}
		</div>');
	}

	static function ArrayForm(props: {name: String, subType: PropTypeEnum, value: Array<Dynamic>, onChange: Array<Dynamic>->Void}) {
		var array = props.value;
		var subType = props.subType;
		if (array == null || !Type.typeof(array).match(TClass(Array))) {
			array = [];
		}
		var fields = [for (i in 0...array.length) {
			var itemValue = array[i];
			function onChange(newItemValue: Dynamic) {
				array[i] = newItemValue;
				props.onChange(array);
			}
			function delete() {
				array.splice(i, 1);
				props.onChange(array);
			}
			function moveUp() {
				if (i == 0) return;

				var currentElement = array[i];
				array.splice(i, 1);
				array.insert(i - 1, currentElement);
				props.onChange(array);
			}
			function moveDown() {
				if (i >= array.length) return;

				var currentElement = array[i];
				array.splice(i, 1);
				array.insert(i + 1, currentElement);
				props.onChange(array);
			}
			var field = renderField('${props.name} ($i)', subType, itemValue, onChange, true);
			jsx('<div key=${i}>
				<div className="ArrayForm__toolbar">
					<IconButton onClick=${moveUp} text="Move Up">⬆️</IconButton>
					<IconButton onClick=${moveDown} text="Move Down">⬇️</IconButton>
					<IconButton onClick=${delete} text="Delete Item">🚮</IconButton>
				</div>
				${field}
			</div>');
		}];
		function addItem() {
			array.push(getDefaultValue(subType));
			props.onChange(array);
		}
		return jsx('<section classame="ContentEditorForm__section">
			<h3 className="ContentEditorForm__h3">${props.name} <small>(Multiple Items)</small></h3>
			${fields}
			<p><IconButton onClick=${addItem} text="Add Item">➕</IconButton></p>
		</section>');
	}

	static function ObjectForm(props: {name: String, subType: PropTypeEnum, value: Dynamic<Dynamic>, onChange: Dynamic<Dynamic>->Void}) {
		var object = props.value;
		var subType = props.subType;
		if (object == null || !Type.typeof(object).match(TObject)) {
			object = {};
		}
		var i = 0;
		var fields = [for (propName in Reflect.fields(object)) {
			var itemValue = Reflect.field(object, propName);
			function onChangeValue(newItemValue: Dynamic) {
				Reflect.setField(object, propName, newItemValue);
				props.onChange(object);
			}
			function onChangeName(e) {
				var newPropName = e.target.value;
				if (newPropName == propName) {
					return;
				}

				var value = Reflect.field(object, propName);
				Reflect.deleteField(object, propName);
				Reflect.setField(object, newPropName, value);
				props.onChange(object);
			}
			function delete() {
				Reflect.deleteField(object, propName);
				props.onChange(object);
			}
			var field = renderField(propName, subType, itemValue, onChangeValue, true);
			jsx('<div key=${i} className="ObjectForm__container">
				<input type="text" onChange=${onChangeName} defaultValue=${propName} />
				${field}
				<IconButton onClick=${delete} text="Delete Field">🚮</IconButton>
			</div>');
		}];
		function addItem() {
			Reflect.setField(object, 'untitled', getDefaultValue(subType));
			props.onChange(object);
		}
		return jsx('<div className="ContentEditorForm__section">
			<h3 class="ContentEditorForm__h3">${props.name} <small>(Multiple Named Items)</small></h3>
			${fields}
			<IconButton onClick=${addItem} text="Add Field">➕</IconButton>
		</div>');
	}
}

class OneOfTypeForm extends UniversalComponent<{
	name: String,
	types: Array<PropTypeEnum>,
	value: Dynamic,
	onChange: Dynamic->Void
}, {
	selectedType: PropTypeEnum
}> {
	public function new(props) {
		super(props);
		this.state = {
			selectedType: switch Type.typeof(props.value) {
				case TClass(String): PTString(true);
				case TClass(Array): PTArray(true);
				case TBool: PTBool(true);
				case TFloat: PTNumber(true);
				case TInt: PTInteger(true);
				case TObject: PTObject(true);
				default:
					// We should probably handle unknown values more gracefully.
					PTString(true);
			}
		};
	}

	override public function render() {
		var field = ContentEditorForm.renderField(
			props.name,
			state.selectedType,
			props.value,
			props.onChange
		);
		var types = getTypes();[
			'String' => PTString(true),
			'Number' => PTNumber(true),
			'Integer' => PTInteger(true),
			'Bool' => PTBool(true),
			'Array' => PTArray(true),
			'Object' => PTObject(true),
		];
		function onChange(val) {
			setState({selectedType: val});
		}
		return jsx('<div className="OneOfTypeForm__container">
			<SelectValues values=${types} selected=${state.selectedType} onChange=${onChange} />
			${field}
		</div>');
	}

	function getTypes() {
		var types = new Map();
		for (typeValue in props.types) {
			var label = getLabelFromType(typeValue);
			types.set(label, typeValue);
		}
		return types;
	}

	function getLabelFromType(type) {
		return switch type {
			case PTString(_): 'String';
			case PTNumber(_): 'Number';
			case PTInteger(_): 'Integer';
			case PTBool(_): 'Boolean';
			case PTArray(_): 'Array';
			case PTObject(_): 'Object';
			case PTShape(_): 'Shaped Object';
			case PTOneOf(_): 'One of';
			case PTOneOfType(types, _): 'Either ${types.map(getLabelFromType).join(", ")}';
			case PTArrayOf(sub, _): 'Array of ${getLabelFromType(sub)}';
			case PTObjectOf(sub, _): 'Object of ${getLabelFromType(sub)}';
			case PTAny(_): 'Any';
		}
	}
}

class SelectValues<T> extends UniversalComponent<{values: Map<String, T>, selected: T, onChange: T->Void}, {}> {
	override public function render() {
		var options = [];
		var selectedLabel = null;
		for (label in props.values.keys()) {
			options.push(jsx('<option key=${label} value=${label}>
				${label}
			</option>'));
			if (props.values[label] == props.selected || Type.enumEq(props.values[label], props.selected)) {
				selectedLabel = label;
			}
		}
		function onChange(e) {
			props.onChange(props.values[e.target.value]);
		}
		return jsx('<select onChange=${onChange} value=${selectedLabel}>
			${options}
		</select>');
	}
}