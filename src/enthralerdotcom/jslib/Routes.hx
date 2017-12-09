package enthralerdotcom.jslib;

class Routes {
	public function new() {}

	@:get('/enthraler.js')
	public function enthraler() {
		return CompileTime.readFile('bin/enthraler.js');
	}

	@:get('/enthralerHost.js')
	public function enthralerHost() {
		return CompileTime.readFile('bin/enthralerHost.js');
	}

	@:get('/frame.html')
	public function frame() {
		return CompileTime.readFile('bin/frame.html');
	}
}