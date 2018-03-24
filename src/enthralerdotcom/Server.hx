package enthralerdotcom;

import smalluniverse.*;
import dodrugs.Injector;
import sys.db.*;
import sys.FileSystem;
import sys.io.File;
import tink.http.containers.*;
import tink.http.Handler;
import tink.web.routing.*;
import tink.http.middleware.Static;
import tink.http.Response.OutgoingResponse;
import enthralerdotcom.types.Url;
using tink.CoreApi;

class Server {
	static function main() {
		SmallUniverse.captureTraces();
		var cnxSettings = {
			host: Sys.getEnv('DB_HOST'),
			database: Sys.getEnv('DB_DATABASE'),
			user: Sys.getEnv('DB_USERNAME'),
			pass: Sys.getEnv('DB_PASSWORD'),
		};
		trace('Connect to ${cnxSettings.user}@${cnxSettings.host}');
		if (FileSystem.exists('conf/db.json')) {
			cnxSettings = tink.Json.parse(File.getContent('conf/db.json'));
		}
		#if nodejs
			var driver = new tink.sql.drivers.MySql({
				user: cnxSettings.user,
				password: cnxSettings.pass,
				host: cnxSettings.host
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
			var siteUrl:Url = Constants.siteUrl,
			var jsLibBaseUrl:Url = Constants.jsLibBaseUrl,
		]);
	}

	static function webMain(cnx) {
		var container = new NodeContainer(3000);
		var router = new Router<Root>(new Root(getInjector(cnx)));
		var handler:Handler = function(req: tink.http.Request.IncomingRequest) {
			trace('[${req.clientIp}] ${req.header.method}: ${req.header.url}');
			return router.route(Context.ofRequest(req))
				.recover(OutgoingResponse.reportError);
		};
		container
			.run(handler.applyMiddleware(new Static('assets', '/assets/')))
			.handle(function (status) {
				switch status {
					case Running(arg1):
						trace('Running: Listening on port 3000');
					case Failed(err):
						trace('Error starting server: $err');
					case Shutdown:
						trace('Shutdown successful');
				};
			});
	}

	static function cliMain(db) {
		// TODO: this line doesn't need to be here, except dodrugs is throwing an error without it. Need to investigate.
		var injector = getInjector(db);
		Promise.inParallel([
			db.AnonymousContentAuthor.create(),
			db.Content.create(),
			db.ContentVersion.create(),
			db.ContentResource.create(),
			db.ContentResourceJoinContentVersion.create(),
			db.ContentAnalyticsEvent.create(),
			db.Template.create(),
			db.TemplateVersion.create()
		]).handle(function (outcome) {
			switch outcome {
				case Success(_):
					trace('Migrations complete');
					Sys.exit(0);
				case Failure(err):
					haxe.Log.trace(err.message, err.pos);
					Sys.exit(1);
			}
		});
	}
}

class Root {
	var injector:Injector<"enthralerdotcom">;

	public function new(injector) {
		this.injector = injector;
	}

	@:sub('/templates')
	public function templates() return new enthralerdotcom.templates.Routes(injector);

	@:sub('/i')
	public function content() return new enthralerdotcom.content.Routes(injector);

	@:sub('/api')
	public function api() return new enthralerdotcom.api.Routes(injector);

	@:all('/')
	public function homepage(context: Context) {
		return new SmallUniverse(function () {
			return injector.instantiate(enthralerdotcom.homepage.HomePage);
		}, context);
	}
}
