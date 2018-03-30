package enthralerdotcom.types;

import tink.sql.Types;

abstract Url(VarChar<255>) from String to String {

	/** The protocol, not including `://`. eg `https` or `http` **/
	public var protocol(get, never): String;

	/** The hostname. eg `enthraler.com` **/
	public var hostname(get, never): String;

	/** The port, if explicitly specified. eg `80` **/
	public var port(get, never): Null<Int>;

	/** The URI path, including the leading slash, not including query or hash. eg `/api/oembed` **/
	public var uri(get, never): String;

	/** The query string, not including the `?`. eg `type=json&maxWidth=1200` **/
	public var queryString(get, never): String;

	/** The hash, not including the `#`. eg `main-content`. **/
	public var hash(get, never): String;

	/** The http origin - including protocol, domain and port. eg `https://enthraler.com:443`. **/
	public var origin(get, never): String;

	public function new(url:String) {
		this = url;
	}

	inline function get_protocol() return this.split("://")[0];

	inline function get_hostAndPort() return this.split("://")[1].split("/")[0];

	function get_hostname() {
		var hostAndPort = get_hostAndPort();
		if (hostAndPort.indexOf(':') > -1) {
			return hostAndPort.split(':')[0];
		}
		return hostAndPort;
	}

	function get_port(): Null<Int> {
		var hostAndPort = get_hostAndPort();
		if (hostAndPort.indexOf(':') > -1) {
			return Std.parseInt(hostAndPort.split(':')[1]);
		}
		return null;
	}

	function get_uri() {
		var afterProtocol = this.split("://")[1];
		var startOfUri = afterProtocol.indexOf('/');
		var startOfQuery = afterProtocol.indexOf('?');
		if (startOfUri == -1) {
			return "";
		}
		if (startOfQuery == -1) {
			return afterProtocol.substr(startOfUri + 1);
		}
		return afterProtocol.substring(startOfUri + 1, startOfQuery);
	}

	function get_queryString() {
		var afterProtocol = this.split("://")[1];
		var startOfQuery = afterProtocol.indexOf('?');
		var startOfHash = afterProtocol.indexOf('#');
		if (startOfQuery == -1) {
			return '';
		} else if (startOfHash == -1) {
			return afterProtocol.substr(startOfQuery + 1);
		}
		return afterProtocol.substring(startOfQuery + 1, afterProtocol.indexOf('#'));
	}

	function get_hash() {
		var afterProtocol = this.split("://")[1];
		var startOfHash = afterProtocol.indexOf('#');
		if (startOfHash == -1) {
			return '';
		}
		return afterProtocol.substring(startOfHash + 1);
	}

	function get_origin() {
		return '$protocol://${get_hostAndPort()}';
	}
}
