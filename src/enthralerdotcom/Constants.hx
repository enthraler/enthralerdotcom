package enthralerdotcom;

import enthralerdotcom.types.Url;

// TODO: load these through environment variables like we do our DB config.
class Constants {
	public static var siteUrl(default, null): Url = new Url(
		#if debug 'http://localhost:8080/'
		#else 'https://enthraler.com/' #end
	);
	public static var jsLibBaseUrl(default, null): Url = new Url(
		#if debug 'http://localhost:2000/bin'
		#else 'https://cdn.rawgit.com/enthraler/enthraler/0.1.0/bin' #end
	);
}