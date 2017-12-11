package enthralerdotcom.templates;

import enthralerdotcom.templates.Template;
import enthralerdotcom.types.*;
import tink.sql.types.*;

// @:index(templateID, major, minor, patch, unique)
typedef TemplateVersion = {
	id: Id<TemplateVersion>,
	created: DateTime,
	updated: DateTime,
	templateId: Id<Template>,
	major: Integer<8>,
	minor: Integer<8>,
	patch: Integer<8>,
	baseUrl: Url,
	mainUrl: Url,
	schemaUrl: Url,
	name: Text<255>,
	description: Text<"">,
	readme: Null<Text<"">>,
	homepage: Url
}

class TemplateVersionUtil {
	public static function getSemver(v: TemplateVersion) {
		return new SemVer('${v.major}.${v.minor}.${v.patch}');
	}
}