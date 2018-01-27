package enthralerdotcom.jslib;

import tink.http.Response;
import tink.http.Header;

class Routes {
	public function new() {}

	@:get('/enthraler.js')
	public function enthraler() {
		var header = new ResponseHeader(OK, 200, [
			new HeaderField('Content-Type', 'application/json')
		]);
		return new OutgoingResponse(header, CompileTime.readFile('bin/enthraler.js'));
	}

	@:produces('application/javascript')
	@:get('/enthralerHost.js')
	public function enthralerHost() {
		var header = new ResponseHeader(OK, 200, [
			new HeaderField('Content-Type', 'application/json')
		]);
		return new OutgoingResponse(header, CompileTime.readFile('bin/enthralerHost.js'));
	}

	@:get('/frame.html')
	public function frame() {
		var header = new ResponseHeader(OK, 200, [
			new HeaderField('Content-Type', 'text/html')
		]);
		return new OutgoingResponse(header, CompileTime.readFile('bin/frame.html'));
	}
}