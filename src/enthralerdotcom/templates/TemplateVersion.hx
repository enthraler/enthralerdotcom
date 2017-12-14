package enthralerdotcom.templates;

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
	var name(default, null): Text<255>;
	var description(default, null): Text<9999999>;
	var readme(default, null): Null<Text<9999999>>;
	var homepage(default, null): Url;
}

class TemplateVersionUtil {
	public static function getSemver(v: TemplateVersion) {
		return new SemVer('${v.major}.${v.minor}.${v.patch}');
	}
}