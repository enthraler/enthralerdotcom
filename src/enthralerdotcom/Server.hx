package enthralerdotcom;

import smalluniverse.*;
import dodrugs.Injector;
import sys.db.*;
import sys.FileSystem;
import sys.io.File;
import ufront.db.migrations.*;
import tink.http.containers.*;
import tink.http.Handler;
import tink.web.routing.*;
import tink.http.middleware.Static;
import tink.http.Response.OutgoingResponse;
using tink.core.Outcome;

class Server {
	static function main() {
		var cnxSettings = {
			host: Sys.getEnv('DB_HOST'),
			database: Sys.getEnv('DB_DATABASE'),
			user: Sys.getEnv('DB_USERNAME'),
			pass: Sys.getEnv('DB_PASSWORD'),
		};
		if (FileSystem.exists('conf/db.json')) {
			cnxSettings = tink.Json.parse(File.getContent('conf/db.json'));
		}
		#if nodejs
			var driver = new tink.sql.drivers.MySql({
				user: cnxSettings.user,
				password: cnxSettings.pass
			});
			var db = new Db('enthraler', driver);
			if (Sys.args()[0] == '--migrate') {
				cliMain(db);
			} else {
				webMain(db);
			}
		#else
			Manager.cnx = Mysql.connect(cnxSettings);
			if (php.Web.isModNeko) {
				webMain(Manager.cnx);
			} else {
				cliMain(Manager.cnx);
			}
		#end

	}

	static function getInjector(db: Db) {
		return Injector.create('enthralerdotcom', [
			var _:Db = db,
			// MigrationConnection,
			// MigrationManager,
			// MigrationApi,
		]);
	}

	static function webMain(cnx) {
		SmallUniverse.captureTraces();

		var container = new NodeContainer(3000);
		var router = new Router<Root>(new Root(getInjector(cnx)));
		var handler:Handler = function(req) {
			return router.route(Context.ofRequest(req))
				.recover(OutgoingResponse.reportError);
		};
		container
			.run(handler.applyMiddleware(new Static('assets', '/assets/')))
			.handle(function (status) {
				switch status {
					case Running(arg1):
						trace('Running: Listening on port 8080');
					case Failed(err):
						trace('Error starting server: $err');
					case Shutdown:
						trace('Shutdown successful');
				};
			});
	}

	static function cliMain(db) {
		var injector = getInjector(db);
		// var migrationApi = injector.get(MigrationApi);
		// migrationApi.ensureMigrationsTableExists();
		// migrationApi.syncMigrationsUp().sure();
		trace('Migrations complete');
	}
}

class Root {
	var injector:Injector<"enthralerdotcom">;

	public function new(injector) {
		this.injector = injector;
	}

	@:sub('/jslib/v1/')
	public function jsLib() return new enthralerdotcom.jslib.Routes();

	@:sub('/templates')
	public function templates() return new enthralerdotcom.templates.Routes(injector);

	@:sub('/i')
	public function content() return new enthralerdotcom.content.Routes(injector);

	@:all('/')
	public function homepage(context: Context) {
		return new SmallUniverse(function () {
			return injector.instantiate(enthralerdotcom.homepage.HomePage);
		}, context);
	}
}
