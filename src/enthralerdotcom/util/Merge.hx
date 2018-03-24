package enthralerdotcom.util;

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
using tink.MacroApi;
using Lambda;
#end

class Merge {
	/**
	Create a new anonymous object by merging the values of one or more anonymous objects.
	**/
	public static macro function object(objects: Array<Expr>) {
		var mergedFields: Map<String, {field: String, expr: Expr}> = new Map();
		for (obj in objects) {
			var type = Context.follow(obj.typeof().sure());
			switch type {
				case TAnonymous(anonType):
					for (field in anonType.get().fields) {
						var name = field.name;
						var fieldType = field.type;
						var existingField = mergedFields[name];
						if (existingField != null) {
							var existingType = Context.typeof(existingField.expr);
							if (Context.unify(fieldType, existingType)) {
								existingField.expr = macro $obj.$name;
							} else {
								obj.reject('We expected the field $name in ${obj.toString()} to be a ${existingType.getID()}');
							}
						} else {
							var ct = fieldType.toComplex();
							mergedFields[name] = {
								field: name,
								expr: macro ($obj.$name: $ct)
							};
						}
					}
				default:
					obj.reject('Merge.object() only works with anonymous objects, but ${obj.toString()} was ${type}');
			}
		}
		return {
			expr: EObjectDecl([for (field in mergedFields) field]),
			pos: Context.currentPos(),
		};
	}
}