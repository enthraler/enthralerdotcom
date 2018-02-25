package enthralerdotcom.components;

import smalluniverse.UniversalPageHead;

class Head {
	public static function prepareHead(head: UniversalPageHead, ?guid: String) {
		head.addMeta('viewport', 'width=device-width, initial-scale=1');
		head.addScript('/assets/enthralerdotcom.bundle.js');
		head.addStylesheet('/assets/styles.css');
		if (guid != null) {
			var url = StringTools.urlEncode('https://enthraler.com/i/$guid/');
			head.addLink('alternate', 'https://enthraler.com/api/oembed/?url=$url&format=json', 'application/json+oembed', 'Enthraler OEmbed JSON API');
			head.addLink('alternate', 'https://enthraler.com/api/oembed/?url=$url&format=xml', 'text/xml+oembed', 'Enthraler OEmbed XML API');
		}
	}
}
