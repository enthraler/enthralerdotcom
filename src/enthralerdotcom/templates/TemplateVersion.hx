package enthralerdotcom.templates;

import enthralerdotcom.Db;
import enthralerdotcom.templates.Template;
import enthralerdotcom.types.*;
import tink.sql.types.*;

// @:index(templateID, major, minor, patch, unique)
typedef TemplateVersion = {
	var id(default, null): Id<TemplateVersion>;
	var created(default, null): DateTime;
	var updated(default, null): DateTime;
	var templateId(default, null): Id<Template>;
	var major(default, null): Integer<8>;
	var minor(default, null): Integer<8>;
	var patch(default, null): Integer<8>;
	var baseUrl(default, null): Url;
	var mainUrl(default, null): Url;
	var schemaUrl(default, null): Url;
	var readme(default, null): Null<Text<9999999>>;
}

class TemplateVersionUtil {
	public static function getSemver(v: TemplateVersion) {
		return new SemVer('${v.major}.${v.minor}.${v.patch}');
	}

	public static function orderBySemver(db: Db, ?desc = true) {
		return function (_:Dynamic):tink.sql.OrderBy<Dynamic> {
			return [{
				field: db.TemplateVersion.fields.major,
				order: desc ? Desc : Asc
			},
			{
				field: db.TemplateVersion.fields.minor,
				order: desc ? Desc : Asc
			},
			{
				field: db.TemplateVersion.fields.patch,
				order: desc ? Desc : Asc
			}];
		}
	}
}