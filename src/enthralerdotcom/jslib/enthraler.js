// Generated by Haxe 3.4.4
(function ($global) { "use strict";
function $extend(from, fields) {
	function Inherit() {} Inherit.prototype = from; var proto = new Inherit();
	for (var name in fields) proto[name] = fields[name];
	if( fields.toString !== Object.prototype.toString ) proto.toString = fields.toString;
	return proto;
}
var EnthralerFrame = function() { };
EnthralerFrame.__name__ = ["EnthralerFrame"];
EnthralerFrame.main = function() {
	var params = EnthralerFrame.getParamsFromLocation();
	EnthralerFrame.loadEnthralerComponent(params);
	var forkLink = window.document.getElementById("enthraler-fork-link");
	var hash = window.location.hash;
	forkLink.href = "/editor.html" + hash;
};
EnthralerFrame.getParamsFromLocation = function() {
	var hash = window.location.hash;
	var paramStrings = HxOverrides.substr(hash,hash.indexOf("?") + 1,null).split("&");
	var params = new haxe_ds_StringMap();
	var _g = 0;
	while(_g < paramStrings.length) {
		var str = paramStrings[_g];
		++_g;
		var parts = str.split("=");
		var v = parts[1];
		var key = parts[0];
		if(__map_reserved[key] != null) {
			params.setReserved(key,v);
		} else {
			params.h[key] = v;
		}
	}
	return params;
};
EnthralerFrame.loadEnthralerComponent = function(params) {
	var container = window.document.getElementById("container");
	enthraler_Enthraler.loadComponent(__map_reserved["template"] != null ? params.getReserved("template") : params.h["template"],__map_reserved["authorData"] != null ? params.getReserved("authorData") : params.h["authorData"],container).then(function(enthralerInstance) {
		window.addEventListener("message",function(e) {
			var message = e.data;
			var data = JSON.parse(message);
			var _g = data.context;
			if(_g == "enthraler.receive.authordata") {
				enthralerInstance.render(data.authorData);
			} else {
				haxe_Log.trace("Received message from host",{ fileName : "EnthralerFrame.hx", lineNumber : 54, className : "EnthralerFrame", methodName : "loadEnthralerComponent", customParams : [data]});
			}
		});
	});
};
var HxOverrides = function() { };
HxOverrides.__name__ = ["HxOverrides"];
HxOverrides.substr = function(s,pos,len) {
	if(len == null) {
		len = s.length;
	} else if(len < 0) {
		if(pos == 0) {
			len = s.length + len;
		} else {
			return "";
		}
	}
	return s.substr(pos,len);
};
Math.__name__ = ["Math"];
var Reflect = function() { };
Reflect.__name__ = ["Reflect"];
Reflect.field = function(o,field) {
	try {
		return o[field];
	} catch( e ) {
		return null;
	}
};
Reflect.fields = function(o) {
	var a = [];
	if(o != null) {
		var hasOwnProperty = Object.prototype.hasOwnProperty;
		for( var f in o ) {
		if(f != "__id__" && f != "hx__closures__" && hasOwnProperty.call(o,f)) {
			a.push(f);
		}
		}
	}
	return a;
};
var _$RequireJs_Module_$Impl_$ = {};
_$RequireJs_Module_$Impl_$.__name__ = ["_RequireJs","Module_Impl_"];
_$RequireJs_Module_$Impl_$._new = function(module) {
	var this1;
	if(Object.prototype.hasOwnProperty.call(module,"default")) {
		this1 = _$RequireJs_Module_$Impl_$._new(Reflect.field(module,"default"));
	} else {
		this1 = module;
	}
	return this1;
};
_$RequireJs_Module_$Impl_$.fromDynamic = function(obj) {
	return _$RequireJs_Module_$Impl_$._new(obj);
};
_$RequireJs_Module_$Impl_$.getStaticField = function(this1,key) {
	return Reflect.field(this1,key);
};
_$RequireJs_Module_$Impl_$.instantiate = function(this1,arg1,arg2,arg3,arg4,arg5) {
	return _$RequireJs_Module_$Impl_$.inst(this1,arg1,arg2,arg3,arg4,arg5);
};
_$RequireJs_Module_$Impl_$.inst = function(loadedModule,arg1,arg2,arg3,arg4,arg5) {
	if(Object.prototype.hasOwnProperty.call(loadedModule,"default")) {
		loadedModule = Reflect.field(loadedModule,"default");
	}
	return new loadedModule(arg1, arg2, arg3, arg4, arg5);
};
var Std = function() { };
Std.__name__ = ["Std"];
Std.string = function(s) {
	return js_Boot.__string_rec(s,"");
};
var ValueType = { __ename__ : ["ValueType"], __constructs__ : ["TNull","TInt","TFloat","TBool","TObject","TFunction","TClass","TEnum","TUnknown"] };
ValueType.TNull = ["TNull",0];
ValueType.TNull.__enum__ = ValueType;
ValueType.TInt = ["TInt",1];
ValueType.TInt.__enum__ = ValueType;
ValueType.TFloat = ["TFloat",2];
ValueType.TFloat.__enum__ = ValueType;
ValueType.TBool = ["TBool",3];
ValueType.TBool.__enum__ = ValueType;
ValueType.TObject = ["TObject",4];
ValueType.TObject.__enum__ = ValueType;
ValueType.TFunction = ["TFunction",5];
ValueType.TFunction.__enum__ = ValueType;
ValueType.TClass = function(c) { var $x = ["TClass",6,c]; $x.__enum__ = ValueType; return $x; };
ValueType.TEnum = function(e) { var $x = ["TEnum",7,e]; $x.__enum__ = ValueType; return $x; };
ValueType.TUnknown = ["TUnknown",8];
ValueType.TUnknown.__enum__ = ValueType;
var Type = function() { };
Type.__name__ = ["Type"];
Type.getClassName = function(c) {
	var a = c.__name__;
	if(a == null) {
		return null;
	}
	return a.join(".");
};
Type.getEnumName = function(e) {
	var a = e.__ename__;
	return a.join(".");
};
Type["typeof"] = function(v) {
	var _g = typeof(v);
	switch(_g) {
	case "boolean":
		return ValueType.TBool;
	case "function":
		if(v.__name__ || v.__ename__) {
			return ValueType.TObject;
		}
		return ValueType.TFunction;
	case "number":
		if(Math.ceil(v) == v % 2147483648.0) {
			return ValueType.TInt;
		}
		return ValueType.TFloat;
	case "object":
		if(v == null) {
			return ValueType.TNull;
		}
		var e = v.__enum__;
		if(e != null) {
			return ValueType.TEnum(e);
		}
		var c = js_Boot.getClass(v);
		if(c != null) {
			return ValueType.TClass(c);
		}
		return ValueType.TObject;
	case "string":
		return ValueType.TClass(String);
	case "undefined":
		return ValueType.TNull;
	default:
		return ValueType.TUnknown;
	}
};
Type.enumEq = function(a,b) {
	if(a == b) {
		return true;
	}
	try {
		if(a[0] != b[0]) {
			return false;
		}
		var _g1 = 2;
		var _g = a.length;
		while(_g1 < _g) {
			var i = _g1++;
			if(!Type.enumEq(a[i],b[i])) {
				return false;
			}
		}
		var e = a.__enum__;
		if(e != b.__enum__ || e == null) {
			return false;
		}
	} catch( e1 ) {
		return false;
	}
	return true;
};
var enthraler_Enthraler = function() { };
enthraler_Enthraler.__name__ = ["enthraler","Enthraler"];
enthraler_Enthraler.loadComponent = function(templateUrl,dataUrl,container) {
	var componentMeta = enthraler_Enthraler.buildEnthralerMeta(templateUrl,dataUrl);
	var environment = new enthraler_Environment(container,componentMeta);
	enthraler_Enthraler.requireJsInit(componentMeta.template.path);
	var url = templateUrl;
	var componentClassPromise = new Promise(function(resolve,reject) {
		$global.require([url],function(module) {
			var componentClassPromise1 = _$RequireJs_Module_$Impl_$._new(module);
			resolve(componentClassPromise1);
		},reject);
	});
	var dataPromise = window.fetch(dataUrl).then(function(r) {
		return r.json();
	});
	return Promise.all([componentClassPromise,dataPromise]).then(function(arr) {
		var componentCls = arr[0];
		var authorData = arr[1];
		var schemaUrl = Reflect.field(componentCls,"enthralerSchema") != null ? Reflect.field(componentCls,"enthralerSchema") : "";
		environment.broadcastSchemaUrl(schemaUrl);
		var component = _$RequireJs_Module_$Impl_$.inst(componentCls,environment,null,null,null,null);
		component.render(authorData);
		return component;
	});
};
enthraler_Enthraler.requireJsInit = function(baseUrl) {
	requirejs.config({ baseUrl : baseUrl, enforceDefine : true, paths : { "cdnjs" : "https://cdnjs.cloudflare.com/ajax/libs/", "jquery" : "https://cdnjs.cloudflare.com/ajax/libs/jquery/1.12.4/jquery.min"}, map : { "*" : { "css" : "https://cdnjs.cloudflare.com/ajax/libs/require-css/0.1.8/css.min.js"}}});
	$global.define("enthraler",[],{ Validators : enthraler_proptypes_Validators, PropTypes : enthraler_proptypes__$PropTypes_PropTypes_$Impl_$},null);
};
enthraler_Enthraler.buildEnthralerMeta = function(templateUrl,dataUrl) {
	return { template : { url : templateUrl, path : haxe_io_Path.addTrailingSlash(haxe_io_Path.directory(templateUrl))}, content : { url : dataUrl, path : haxe_io_Path.addTrailingSlash(haxe_io_Path.directory(dataUrl))}};
};
var enthraler_Environment = function(container,meta) {
	this.container = container;
	this.meta = meta;
};
enthraler_Environment.__name__ = ["enthraler","Environment"];
enthraler_Environment.prototype = {
	requestHeightChange: function(requestedHeight) {
		if(window.parent == null) {
			return;
		}
		if(requestedHeight == null) {
			requestedHeight = window.document.documentElement.scrollHeight + 1;
		}
		window.parent.postMessage(JSON.stringify({ src : "" + Std.string(window.location), context : "iframe.resize", height : requestedHeight}),"*");
	}
	,broadcastSchemaUrl: function(schemaUrl) {
		if(window.parent == null) {
			return;
		}
		window.parent.postMessage(JSON.stringify({ src : "" + Std.string(window.location), context : "enthraler.broadcast.schemaUrl", schemaUrl : schemaUrl}),"*");
	}
	,__class__: enthraler_Environment
};
var enthraler_proptypes__$PropTypes_PropTypes_$Impl_$ = {};
enthraler_proptypes__$PropTypes_PropTypes_$Impl_$.__name__ = ["enthraler","proptypes","_PropTypes","PropTypes_Impl_"];
enthraler_proptypes__$PropTypes_PropTypes_$Impl_$.keys = function(this1) {
	return Reflect.fields(this1);
};
enthraler_proptypes__$PropTypes_PropTypes_$Impl_$.get = function(this1,key) {
	var value = Reflect.field(this1,key);
	if(typeof(value) == "string") {
		var propTypeName = enthraler_proptypes__$PropTypes_SimplePropTypeName_$Impl_$.fromString(value);
		return propTypeName;
	}
	return value;
};
enthraler_proptypes__$PropTypes_PropTypes_$Impl_$.fromObject = function(obj) {
	return obj;
};
var enthraler_proptypes__$PropTypes_PropType_$Impl_$ = {};
enthraler_proptypes__$PropTypes_PropType_$Impl_$.__name__ = ["enthraler","proptypes","_PropTypes","PropType_Impl_"];
enthraler_proptypes__$PropTypes_PropType_$Impl_$.getOriginalValue = function(this1) {
	return this1;
};
enthraler_proptypes__$PropTypes_PropType_$Impl_$.getDescription = function(this1) {
	if(typeof(this1) == "string") {
		var type = this1;
		var optional = false;
		if(HxOverrides.substr(type,0,1) == "?") {
			optional = true;
			type = HxOverrides.substr(type,1,null);
		}
		return { type : type, optional : optional};
	}
	return this1;
};
enthraler_proptypes__$PropTypes_PropType_$Impl_$.getEnum = function(this1) {
	var description = enthraler_proptypes__$PropTypes_PropType_$Impl_$.getDescription(this1);
	var optional = description.optional == true;
	var _g = description.type;
	switch(_g) {
	case "any":
		return enthraler_proptypes_PropTypeEnum.PTAny(optional);
	case "array":
		return enthraler_proptypes_PropTypeEnum.PTArray(optional);
	case "arrayOf":
		return enthraler_proptypes_PropTypeEnum.PTArrayOf(enthraler_proptypes__$PropTypes_PropType_$Impl_$.getEnum(description.subType),optional);
	case "bool":
		return enthraler_proptypes_PropTypeEnum.PTBool(optional);
	case "integer":
		return enthraler_proptypes_PropTypeEnum.PTInteger(optional);
	case "number":
		return enthraler_proptypes_PropTypeEnum.PTNumber(optional);
	case "object":
		return enthraler_proptypes_PropTypeEnum.PTObject(optional);
	case "objectOf":
		return enthraler_proptypes_PropTypeEnum.PTObjectOf(enthraler_proptypes__$PropTypes_PropType_$Impl_$.getEnum(description.subType),optional);
	case "oneOf":
		return enthraler_proptypes_PropTypeEnum.PTOneOf(description.values,optional);
	case "oneOfType":
		return enthraler_proptypes_PropTypeEnum.PTOneOfType(description.subTypes.map(function(s) {
			return enthraler_proptypes__$PropTypes_PropType_$Impl_$.getEnum(s);
		}),optional);
	case "shape":
		var shape = { };
		var _g1 = 0;
		var _g11 = Reflect.fields(description.shape);
		while(_g1 < _g11.length) {
			var field = _g11[_g1];
			++_g1;
			var subType = Reflect.field(description.shape,field);
			shape[field] = enthraler_proptypes__$PropTypes_PropType_$Impl_$.getEnum(subType);
		}
		return enthraler_proptypes_PropTypeEnum.PTShape(shape,optional);
	case "string":
		return enthraler_proptypes_PropTypeEnum.PTString(optional);
	}
};
enthraler_proptypes__$PropTypes_PropType_$Impl_$.getValidatorFn = function(this1) {
	return enthraler_proptypes_Validators.getValidatorFnFromPropType(enthraler_proptypes__$PropTypes_PropType_$Impl_$.getEnum(this1));
};
enthraler_proptypes__$PropTypes_PropType_$Impl_$.isString = function(value) {
	return typeof(value) == "string";
};
var enthraler_proptypes__$PropTypes_SimplePropTypeName_$Impl_$ = {};
enthraler_proptypes__$PropTypes_SimplePropTypeName_$Impl_$.__name__ = ["enthraler","proptypes","_PropTypes","SimplePropTypeName_Impl_"];
enthraler_proptypes__$PropTypes_SimplePropTypeName_$Impl_$._new = function(str) {
	var this1 = str;
	return this1;
};
enthraler_proptypes__$PropTypes_SimplePropTypeName_$Impl_$.fromString = function(str) {
	var allValidNames = ["array","bool","number","integer","object","string","any","?array","?bool","?number","?integer","?object","?string","?any"];
	if(allValidNames.indexOf(str) == -1) {
		throw new js__$Boot_HaxeError("The type string `" + str + "` is not a valid value. Valid values are " + Std.string(allValidNames));
	}
	return enthraler_proptypes__$PropTypes_SimplePropTypeName_$Impl_$._new(str);
};
var enthraler_proptypes_PropTypeEnum = { __ename__ : ["enthraler","proptypes","PropTypeEnum"], __constructs__ : ["PTArray","PTBool","PTNumber","PTInteger","PTObject","PTString","PTOneOf","PTOneOfType","PTArrayOf","PTObjectOf","PTShape","PTAny"] };
enthraler_proptypes_PropTypeEnum.PTArray = function(optional) { var $x = ["PTArray",0,optional]; $x.__enum__ = enthraler_proptypes_PropTypeEnum; return $x; };
enthraler_proptypes_PropTypeEnum.PTBool = function(optional) { var $x = ["PTBool",1,optional]; $x.__enum__ = enthraler_proptypes_PropTypeEnum; return $x; };
enthraler_proptypes_PropTypeEnum.PTNumber = function(optional) { var $x = ["PTNumber",2,optional]; $x.__enum__ = enthraler_proptypes_PropTypeEnum; return $x; };
enthraler_proptypes_PropTypeEnum.PTInteger = function(optional) { var $x = ["PTInteger",3,optional]; $x.__enum__ = enthraler_proptypes_PropTypeEnum; return $x; };
enthraler_proptypes_PropTypeEnum.PTObject = function(optional) { var $x = ["PTObject",4,optional]; $x.__enum__ = enthraler_proptypes_PropTypeEnum; return $x; };
enthraler_proptypes_PropTypeEnum.PTString = function(optional) { var $x = ["PTString",5,optional]; $x.__enum__ = enthraler_proptypes_PropTypeEnum; return $x; };
enthraler_proptypes_PropTypeEnum.PTOneOf = function(values,optional) { var $x = ["PTOneOf",6,values,optional]; $x.__enum__ = enthraler_proptypes_PropTypeEnum; return $x; };
enthraler_proptypes_PropTypeEnum.PTOneOfType = function(types,optional) { var $x = ["PTOneOfType",7,types,optional]; $x.__enum__ = enthraler_proptypes_PropTypeEnum; return $x; };
enthraler_proptypes_PropTypeEnum.PTArrayOf = function(subType,optional) { var $x = ["PTArrayOf",8,subType,optional]; $x.__enum__ = enthraler_proptypes_PropTypeEnum; return $x; };
enthraler_proptypes_PropTypeEnum.PTObjectOf = function(subType,optional) { var $x = ["PTObjectOf",9,subType,optional]; $x.__enum__ = enthraler_proptypes_PropTypeEnum; return $x; };
enthraler_proptypes_PropTypeEnum.PTShape = function(shape,optional) { var $x = ["PTShape",10,shape,optional]; $x.__enum__ = enthraler_proptypes_PropTypeEnum; return $x; };
enthraler_proptypes_PropTypeEnum.PTAny = function(optional) { var $x = ["PTAny",11,optional]; $x.__enum__ = enthraler_proptypes_PropTypeEnum; return $x; };
var js_Boot = function() { };
js_Boot.__name__ = ["js","Boot"];
js_Boot.__unhtml = function(s) {
	return s.split("&").join("&amp;").split("<").join("&lt;").split(">").join("&gt;");
};
js_Boot.__trace = function(v,i) {
	var msg = i != null ? i.fileName + ":" + i.lineNumber + ": " : "";
	msg += js_Boot.__string_rec(v,"");
	if(i != null && i.customParams != null) {
		var _g = 0;
		var _g1 = i.customParams;
		while(_g < _g1.length) {
			var v1 = _g1[_g];
			++_g;
			msg += "," + js_Boot.__string_rec(v1,"");
		}
	}
	var d;
	var tmp;
	if(typeof(document) != "undefined") {
		d = document.getElementById("haxe:trace");
		tmp = d != null;
	} else {
		tmp = false;
	}
	if(tmp) {
		d.innerHTML += js_Boot.__unhtml(msg) + "<br/>";
	} else if(typeof console != "undefined" && console.log != null) {
		console.log(msg);
	}
};
js_Boot.getClass = function(o) {
	if((o instanceof Array) && o.__enum__ == null) {
		return Array;
	} else {
		var cl = o.__class__;
		if(cl != null) {
			return cl;
		}
		var name = js_Boot.__nativeClassName(o);
		if(name != null) {
			return js_Boot.__resolveNativeClass(name);
		}
		return null;
	}
};
js_Boot.__string_rec = function(o,s) {
	if(o == null) {
		return "null";
	}
	if(s.length >= 5) {
		return "<...>";
	}
	var t = typeof(o);
	if(t == "function" && (o.__name__ || o.__ename__)) {
		t = "object";
	}
	switch(t) {
	case "function":
		return "<function>";
	case "object":
		if(o instanceof Array) {
			if(o.__enum__) {
				if(o.length == 2) {
					return o[0];
				}
				var str = o[0] + "(";
				s += "\t";
				var _g1 = 2;
				var _g = o.length;
				while(_g1 < _g) {
					var i = _g1++;
					if(i != 2) {
						str += "," + js_Boot.__string_rec(o[i],s);
					} else {
						str += js_Boot.__string_rec(o[i],s);
					}
				}
				return str + ")";
			}
			var l = o.length;
			var i1;
			var str1 = "[";
			s += "\t";
			var _g11 = 0;
			var _g2 = l;
			while(_g11 < _g2) {
				var i2 = _g11++;
				str1 += (i2 > 0 ? "," : "") + js_Boot.__string_rec(o[i2],s);
			}
			str1 += "]";
			return str1;
		}
		var tostr;
		try {
			tostr = o.toString;
		} catch( e ) {
			return "???";
		}
		if(tostr != null && tostr != Object.toString && typeof(tostr) == "function") {
			var s2 = o.toString();
			if(s2 != "[object Object]") {
				return s2;
			}
		}
		var k = null;
		var str2 = "{\n";
		s += "\t";
		var hasp = o.hasOwnProperty != null;
		for( var k in o ) {
		if(hasp && !o.hasOwnProperty(k)) {
			continue;
		}
		if(k == "prototype" || k == "__class__" || k == "__super__" || k == "__interfaces__" || k == "__properties__") {
			continue;
		}
		if(str2.length != 2) {
			str2 += ", \n";
		}
		str2 += s + k + " : " + js_Boot.__string_rec(o[k],s);
		}
		s = s.substring(1);
		str2 += "\n" + s + "}";
		return str2;
	case "string":
		return o;
	default:
		return String(o);
	}
};
js_Boot.__nativeClassName = function(o) {
	var name = js_Boot.__toStr.call(o).slice(8,-1);
	if(name == "Object" || name == "Function" || name == "Math" || name == "JSON") {
		return null;
	}
	return name;
};
js_Boot.__resolveNativeClass = function(name) {
	return $global[name];
};
var enthraler_proptypes_ValidationPathPart = { __ename__ : ["enthraler","proptypes","ValidationPathPart"], __constructs__ : ["AccessProperty","AccessArray"] };
enthraler_proptypes_ValidationPathPart.AccessProperty = function(name) { var $x = ["AccessProperty",0,name]; $x.__enum__ = enthraler_proptypes_ValidationPathPart; return $x; };
enthraler_proptypes_ValidationPathPart.AccessArray = function(itemNumber) { var $x = ["AccessArray",1,itemNumber]; $x.__enum__ = enthraler_proptypes_ValidationPathPart; return $x; };
var enthraler_proptypes_ValidationError = function(message,path,childErrors) {
	Error.call(this,message);
	this.name = "ValidationError";
	this.message = message;
	this.path = path;
	if(childErrors != null) {
		this.setChildErrors(childErrors);
	} else {
		this.childErrors = [];
	}
};
enthraler_proptypes_ValidationError.__name__ = ["enthraler","proptypes","ValidationError"];
enthraler_proptypes_ValidationError.__super__ = Error;
enthraler_proptypes_ValidationError.prototype = $extend(Error.prototype,{
	setChildErrors: function(childErrors) {
		var _g = 0;
		while(_g < childErrors.length) {
			var e = childErrors[_g];
			++_g;
			e.parent = this;
		}
		this.childErrors = childErrors;
	}
	,getErrorPath: function() {
		var errorPath;
		var _g = this.path;
		switch(_g[1]) {
		case 0:
			var name = _g[2];
			errorPath = "." + name;
			break;
		case 1:
			var itemNumber = _g[2];
			errorPath = "[" + itemNumber + "]";
			break;
		}
		if(this.parent != null) {
			errorPath = this.parent.getErrorPath() + errorPath;
		}
		return errorPath;
	}
	,toString: function() {
		return this.getErrorPath() + ": " + this.message;
	}
	,__class__: enthraler_proptypes_ValidationError
});
var enthraler_proptypes_Validators = function() { };
enthraler_proptypes_Validators.__name__ = ["enthraler","proptypes","Validators"];
enthraler_proptypes_Validators.validate = function(schema,obj,descriptiveName) {
	var errors = [];
	var _g = 0;
	var _g1 = enthraler_proptypes__$PropTypes_PropTypes_$Impl_$.keys(schema);
	while(_g < _g1.length) {
		var fieldName = _g1[_g];
		++_g;
		var propType = enthraler_proptypes__$PropTypes_PropTypes_$Impl_$.get(schema,fieldName);
		var propValidator = enthraler_proptypes__$PropTypes_PropType_$Impl_$.getValidatorFn(propType);
		var error = propValidator(obj,fieldName,descriptiveName,"property");
		if(error != null) {
			errors.push(error);
		}
	}
	if(errors.length > 0) {
		return errors;
	} else {
		return null;
	}
};
enthraler_proptypes_Validators.getValidatorFnFromPropType = function(pt) {
	switch(pt[1]) {
	case 0:
		var optional = pt[2];
		var check = enthraler_proptypes_Validators.array;
		if(optional) {
			return check;
		} else {
			return enthraler_proptypes_Validators.required(check);
		}
		break;
	case 1:
		var optional1 = pt[2];
		var check1 = enthraler_proptypes_Validators.bool;
		if(optional1) {
			return check1;
		} else {
			return enthraler_proptypes_Validators.required(check1);
		}
		break;
	case 2:
		var optional2 = pt[2];
		var check2 = enthraler_proptypes_Validators.number;
		if(optional2) {
			return check2;
		} else {
			return enthraler_proptypes_Validators.required(check2);
		}
		break;
	case 3:
		var optional3 = pt[2];
		var check3 = enthraler_proptypes_Validators.integer;
		if(optional3) {
			return check3;
		} else {
			return enthraler_proptypes_Validators.required(check3);
		}
		break;
	case 4:
		var optional4 = pt[2];
		var check4 = enthraler_proptypes_Validators.object;
		if(optional4) {
			return check4;
		} else {
			return enthraler_proptypes_Validators.required(check4);
		}
		break;
	case 5:
		var optional5 = pt[2];
		var check5 = enthraler_proptypes_Validators.string;
		if(optional5) {
			return check5;
		} else {
			return enthraler_proptypes_Validators.required(check5);
		}
		break;
	case 6:
		var optional6 = pt[3];
		var values = pt[2];
		var check6 = enthraler_proptypes_Validators.oneOf(values);
		if(optional6) {
			return check6;
		} else {
			return enthraler_proptypes_Validators.required(check6);
		}
		break;
	case 7:
		var optional7 = pt[3];
		var types = pt[2];
		var _g = [];
		var _g1 = 0;
		while(_g1 < types.length) {
			var t = types[_g1];
			++_g1;
			_g.push(enthraler_proptypes_Validators.getValidatorFnFromPropType(t));
		}
		var subTypes = _g;
		var check7 = enthraler_proptypes_Validators.oneOfType(subTypes);
		if(optional7) {
			return check7;
		} else {
			return enthraler_proptypes_Validators.required(check7);
		}
		break;
	case 8:
		var optional8 = pt[3];
		var subType = pt[2];
		var check8 = enthraler_proptypes_Validators.arrayOf(enthraler_proptypes_Validators.getValidatorFnFromPropType(subType));
		if(optional8) {
			return check8;
		} else {
			return enthraler_proptypes_Validators.required(check8);
		}
		break;
	case 9:
		var optional9 = pt[3];
		var subType1 = pt[2];
		var check9 = enthraler_proptypes_Validators.objectOf(enthraler_proptypes_Validators.getValidatorFnFromPropType(subType1));
		if(optional9) {
			return check9;
		} else {
			return enthraler_proptypes_Validators.required(check9);
		}
		break;
	case 10:
		var optional10 = pt[3];
		var shapeObj = pt[2];
		var validatorShape = { };
		var _g2 = 0;
		var _g11 = Reflect.fields(shapeObj);
		while(_g2 < _g11.length) {
			var fieldName = _g11[_g2];
			++_g2;
			var pt1 = Reflect.field(shapeObj,fieldName);
			validatorShape[fieldName] = enthraler_proptypes_Validators.getValidatorFnFromPropType(pt1);
		}
		var check10 = enthraler_proptypes_Validators.shape(validatorShape);
		if(optional10) {
			return check10;
		} else {
			return enthraler_proptypes_Validators.required(check10);
		}
		break;
	case 11:
		var optional11 = pt[2];
		var check11 = enthraler_proptypes_Validators.any;
		if(optional11) {
			return check11;
		} else {
			return enthraler_proptypes_Validators.required(check11);
		}
		break;
	}
};
enthraler_proptypes_Validators.required = function(check) {
	return function(props,propName,descriptiveName,location) {
		var value = Reflect.field(props,propName);
		if(value == null) {
			var errorMsg = "Required " + location + " `" + propName + "` was not specified in `" + descriptiveName + "`";
			return new enthraler_proptypes_ValidationError(errorMsg,enthraler_proptypes_ValidationPathPart.AccessProperty(propName));
		}
		return check(props,propName,descriptiveName,location);
	};
};
enthraler_proptypes_Validators.bool = function(a2,a3,a4,a5) {
	return enthraler_proptypes_Validators.typeCheck(ValueType.TBool,a2,a3,a4,a5);
};
enthraler_proptypes_Validators.number = function(a2,a3,a4,a5) {
	return enthraler_proptypes_Validators.typeCheck(ValueType.TFloat,a2,a3,a4,a5);
};
enthraler_proptypes_Validators.integer = function(a2,a3,a4,a5) {
	return enthraler_proptypes_Validators.typeCheck(ValueType.TInt,a2,a3,a4,a5);
};
enthraler_proptypes_Validators.object = function(a2,a3,a4,a5) {
	return enthraler_proptypes_Validators.typeCheck(ValueType.TObject,a2,a3,a4,a5);
};
enthraler_proptypes_Validators.any = function(a2,a3,a4,a5) {
	return enthraler_proptypes_Validators.typeCheck(ValueType.TUnknown,a2,a3,a4,a5);
};
enthraler_proptypes_Validators.oneOf = function(allowedValues) {
	return function(props,propName,descriptiveName,location) {
		var value = Reflect.field(props,propName);
		if(value != null && allowedValues.indexOf(value) == -1) {
			var errorMsg = "Invalid " + location + " `" + propName + "` had value `" + value + "` supplied to `" + descriptiveName + "`, but expected one of `" + Std.string(allowedValues) + "`";
			return new enthraler_proptypes_ValidationError(errorMsg,enthraler_proptypes_ValidationPathPart.AccessProperty(propName));
		}
		return null;
	};
};
enthraler_proptypes_Validators.oneOfType = function(allowedTypes) {
	return function(props,propName,descriptiveName,location) {
		var _g = 0;
		while(_g < allowedTypes.length) {
			var propValidator = allowedTypes[_g];
			++_g;
			var result = propValidator(props,propName,descriptiveName,location);
			if(result == null) {
				return null;
			}
		}
		var value = Reflect.field(props,propName);
		var actualType = Type["typeof"](value);
		var errorMsg = "Invalid " + location + " `" + propName + "` of type `" + enthraler_proptypes_Validators.typeName(actualType) + "` supplied to `" + descriptiveName + "`";
		return new enthraler_proptypes_ValidationError(errorMsg,enthraler_proptypes_ValidationPathPart.AccessProperty(propName));
	};
};
enthraler_proptypes_Validators.arrayOf = function(type) {
	return function(props,propName,descriptiveName,location) {
		var isNotArray = enthraler_proptypes_Validators.array(props,propName,descriptiveName,location);
		if(isNotArray != null) {
			return isNotArray;
		}
		var values = Reflect.field(props,propName);
		var errors = [];
		var i = 0;
		var _g = 0;
		while(_g < values.length) {
			var value = values[_g];
			++_g;
			var error = type(values,"" + i,descriptiveName,"array item");
			if(error != null) {
				error.path = enthraler_proptypes_ValidationPathPart.AccessArray(i);
				errors.push(error);
			}
			++i;
		}
		if(errors.length > 0) {
			var itemOrItems = errors.length == 1 ? "item" : "items";
			var message = "The array in " + location + " `" + propName + "` contained " + errors.length + " invalid " + itemOrItems;
			return new enthraler_proptypes_ValidationError(message,enthraler_proptypes_ValidationPathPart.AccessProperty(propName),errors);
		}
		return null;
	};
};
enthraler_proptypes_Validators.objectOf = function(type) {
	return function(props,propName,descriptiveName,location) {
		var error = enthraler_proptypes_Validators.typeCheck(ValueType.TObject,props,propName,descriptiveName,location);
		if(error != null) {
			return error;
		}
		var valueObj = Reflect.field(props,propName);
		var errors = [];
		var fields = Reflect.fields(valueObj);
		var _g = 0;
		while(_g < fields.length) {
			var field = fields[_g];
			++_g;
			var error1 = type(valueObj,field,descriptiveName,"field");
			if(error1 != null) {
				errors.push(error1);
			}
		}
		if(errors.length > 0) {
			var fieldOrFields = errors.length == 1 ? "field" : "fields";
			var message = "The object in " + location + " `" + propName + "` contained " + errors.length + " invalid " + fieldOrFields;
			return new enthraler_proptypes_ValidationError(message,enthraler_proptypes_ValidationPathPart.AccessProperty(propName),errors);
		}
		return null;
	};
};
enthraler_proptypes_Validators.shape = function(shape) {
	return function(props,propName,descriptiveName,location) {
		var valueObj = Reflect.field(props,propName);
		var errors = [];
		var propertyPath = enthraler_proptypes_ValidationPathPart.AccessProperty(propName);
		var fields = Reflect.fields(shape);
		var _g = 0;
		while(_g < fields.length) {
			var field = fields[_g];
			++_g;
			var propValidator = Reflect.field(shape,field);
			var error = propValidator(valueObj,field,descriptiveName,"field");
			if(error != null) {
				errors.push(error);
			}
		}
		if(errors.length > 0) {
			var fieldOrFields = errors.length == 1 ? "field" : "fields";
			var message = "The object in " + location + " `" + propName + "` contained " + errors.length + " invalid " + fieldOrFields;
			return new enthraler_proptypes_ValidationError(message,enthraler_proptypes_ValidationPathPart.AccessProperty(propName),errors);
		}
		return null;
	};
};
enthraler_proptypes_Validators.typeCheck = function(expectedType,props,propName,descriptiveName,location) {
	var value = Reflect.field(props,propName);
	if(value == null) {
		return null;
	}
	var actualType = Type["typeof"](value);
	if(Type.enumEq(actualType,expectedType)) {
		return null;
	}
	switch(expectedType[1]) {
	case 2:
		if(actualType[1] == 1) {
			return null;
		}
		break;
	case 4:
		if(actualType[1] == 6) {
			var cls = actualType[2];
			if(cls != String && cls != Array) {
				return null;
			}
		}
		break;
	case 8:
		return null;
	default:
	}
	var errorMsg = "Invalid " + location + " `" + propName + "` of type `" + enthraler_proptypes_Validators.typeName(actualType) + "` supplied to `" + descriptiveName + "`, expected `" + enthraler_proptypes_Validators.typeName(expectedType) + "`";
	return new enthraler_proptypes_ValidationError(errorMsg,enthraler_proptypes_ValidationPathPart.AccessProperty(propName));
};
enthraler_proptypes_Validators.typeName = function(type) {
	switch(type[1]) {
	case 0:
		return "Null Value";
	case 1:
		return "Integer";
	case 2:
		return "Float";
	case 3:
		return "Bool";
	case 4:
		return "Object";
	case 5:
		return "Function";
	case 6:
		switch(type[2]) {
		case Array:
			return "Array";
		case String:
			return "String";
		default:
			var cls = type[2];
			return Type.getClassName(cls) + " Object";
		}
		break;
	case 7:
		var enm = type[2];
		return Type.getEnumName(enm) + " Enum Value";
	case 8:
		return "Unknown Type";
	}
};
var haxe_IMap = function() { };
haxe_IMap.__name__ = ["haxe","IMap"];
var haxe_Log = function() { };
haxe_Log.__name__ = ["haxe","Log"];
haxe_Log.trace = function(v,infos) {
	js_Boot.__trace(v,infos);
};
var haxe_ds_StringMap = function() {
	this.h = { };
};
haxe_ds_StringMap.__name__ = ["haxe","ds","StringMap"];
haxe_ds_StringMap.__interfaces__ = [haxe_IMap];
haxe_ds_StringMap.prototype = {
	setReserved: function(key,value) {
		if(this.rh == null) {
			this.rh = { };
		}
		this.rh["$" + key] = value;
	}
	,getReserved: function(key) {
		if(this.rh == null) {
			return null;
		} else {
			return this.rh["$" + key];
		}
	}
	,__class__: haxe_ds_StringMap
};
var haxe_io_Path = function(path) {
	switch(path) {
	case ".":case "..":
		this.dir = path;
		this.file = "";
		return;
	}
	var c1 = path.lastIndexOf("/");
	var c2 = path.lastIndexOf("\\");
	if(c1 < c2) {
		this.dir = HxOverrides.substr(path,0,c2);
		path = HxOverrides.substr(path,c2 + 1,null);
		this.backslash = true;
	} else if(c2 < c1) {
		this.dir = HxOverrides.substr(path,0,c1);
		path = HxOverrides.substr(path,c1 + 1,null);
	} else {
		this.dir = null;
	}
	var cp = path.lastIndexOf(".");
	if(cp != -1) {
		this.ext = HxOverrides.substr(path,cp + 1,null);
		this.file = HxOverrides.substr(path,0,cp);
	} else {
		this.ext = null;
		this.file = path;
	}
};
haxe_io_Path.__name__ = ["haxe","io","Path"];
haxe_io_Path.directory = function(path) {
	var s = new haxe_io_Path(path);
	if(s.dir == null) {
		return "";
	}
	return s.dir;
};
haxe_io_Path.addTrailingSlash = function(path) {
	if(path.length == 0) {
		return "/";
	}
	var c1 = path.lastIndexOf("/");
	var c2 = path.lastIndexOf("\\");
	if(c1 < c2) {
		if(c2 != path.length - 1) {
			return path + "\\";
		} else {
			return path;
		}
	} else if(c1 != path.length - 1) {
		return path + "/";
	} else {
		return path;
	}
};
haxe_io_Path.prototype = {
	__class__: haxe_io_Path
};
var js__$Boot_HaxeError = function(val) {
	Error.call(this);
	this.val = val;
	this.message = String(val);
	if(Error.captureStackTrace) {
		Error.captureStackTrace(this,js__$Boot_HaxeError);
	}
};
js__$Boot_HaxeError.__name__ = ["js","_Boot","HaxeError"];
js__$Boot_HaxeError.wrap = function(val) {
	if((val instanceof Error)) {
		return val;
	} else {
		return new js__$Boot_HaxeError(val);
	}
};
js__$Boot_HaxeError.__super__ = Error;
js__$Boot_HaxeError.prototype = $extend(Error.prototype,{
	__class__: js__$Boot_HaxeError
});
String.prototype.__class__ = String;
String.__name__ = ["String"];
Array.__name__ = ["Array"];
var __map_reserved = {};
enthraler_proptypes__$PropTypes_SimplePropTypeName_$Impl_$.array = "array";
enthraler_proptypes__$PropTypes_SimplePropTypeName_$Impl_$.bool = "bool";
enthraler_proptypes__$PropTypes_SimplePropTypeName_$Impl_$.number = "number";
enthraler_proptypes__$PropTypes_SimplePropTypeName_$Impl_$.integer = "integer";
enthraler_proptypes__$PropTypes_SimplePropTypeName_$Impl_$.object = "object";
enthraler_proptypes__$PropTypes_SimplePropTypeName_$Impl_$.string = "string";
enthraler_proptypes__$PropTypes_SimplePropTypeName_$Impl_$.any = "any";
enthraler_proptypes__$PropTypes_SimplePropTypeName_$Impl_$.optionalArray = "?array";
enthraler_proptypes__$PropTypes_SimplePropTypeName_$Impl_$.optionalBool = "?bool";
enthraler_proptypes__$PropTypes_SimplePropTypeName_$Impl_$.optionalNumber = "?number";
enthraler_proptypes__$PropTypes_SimplePropTypeName_$Impl_$.optionalInteger = "?integer";
enthraler_proptypes__$PropTypes_SimplePropTypeName_$Impl_$.optionalObject = "?object";
enthraler_proptypes__$PropTypes_SimplePropTypeName_$Impl_$.optionalString = "?string";
enthraler_proptypes__$PropTypes_SimplePropTypeName_$Impl_$.optionalAny = "?any";
js_Boot.__toStr = ({ }).toString;
enthraler_proptypes_Validators.array = (function($this) {
	var $r;
	var a1 = ValueType.TClass(Array);
	$r = function(a2,a3,a4,a5) {
		return enthraler_proptypes_Validators.typeCheck(a1,a2,a3,a4,a5);
	};
	return $r;
}(this));
enthraler_proptypes_Validators.string = (function($this) {
	var $r;
	var a1 = ValueType.TClass(String);
	$r = function(a2,a3,a4,a5) {
		return enthraler_proptypes_Validators.typeCheck(a1,a2,a3,a4,a5);
	};
	return $r;
}(this));
EnthralerFrame.main();
})(typeof window != "undefined" ? window : typeof global != "undefined" ? global : typeof self != "undefined" ? self : this);
