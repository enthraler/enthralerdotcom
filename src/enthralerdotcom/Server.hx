package enthralerdotcom;

import smalluniverse.*;
import dodrugs.Injector;
import sys.db.*;
import sys.FileSystem;
import sys.io.File;
// import ufront.db.migrations.*;
import tink.http.containers.*;
import tink.http.Response;
import tink.http.Handler;
import tink.web.routing.*;
import tink.http.middleware.Static;
import tink.http.Response.OutgoingResponse;
using tink.core.Outcome;

class Server {

	public static var jsLibBase = '/jslib/0.1.1';

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
			MysqlJs.connect(cnxSettings, function (err, cnx) {
				if (err != null) {
					throw err;
				}
				trace('Connected to ${cnxSettings.host}');
				webMain(cnx);
			});
		#else
			Manager.cnx = Mysql.connect(cnxSettings);
			if (php.Web.isModNeko) {
				webMain(Manager.cnx);
			} else {
				cliMain(Manager.cnx);
			}
		#end

	}

	static function getInjector(cnx) {
		return Injector.create('enthralerdotcom', [
			var _:AsyncConnection = cnx,
			var _:Connection = Manager.cnx,
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

		// var app = new Monsoon();
		// app.use('/assets/', Static.serve('assets'));
		// app.use('$jsLibBase/enthraler.js',  function (req,res) res.send(CompileTime.readFile('bin/enthraler.js')));
		// app.use('$jsLibBase/enthralerHost.js', function (req,res) res.send(CompileTime.readFile('bin/enthralerHost.js')));
		// app.use('$jsLibBase/frame.html', function (req,res) res.send(CompileTime.readFile('bin/frame.html')));
		// app.use('/i/:guid/data/:id?', enthralerdotcom.content.ContentServerRoutes.getDataJson);
		// app.use('/i/:guid/embed/:id?', enthralerdotcom.content.ContentServerRoutes.redirectToEmbedFrame);
	}

	static function cliMain(cnx) {
		var injector = getInjector(cnx);
		// var migrationApi = injector.get(MigrationApi);
		// migrationApi.ensureMigrationsTableExists();
		// migrationApi.syncMigrationsUp().sure();
		trace('done');
	}
}

class Root {
	var injector:Injector<"enthralerdotcom">;

    public function new(injector) {
		this.injector = injector;
	}

	@:all('/templates/github/$username/$repo')
	public function viewTemplate(username: String, repo: String, context: Context) {
		return new SmallUniverse(function () {
			return injector.instantiateWith(enthralerdotcom.templates.ViewTemplatePage, [
				username,
				repo,
			]);
		}, context);
	}


	@:all('/templates/')
	public function manageTemplates(context: Context) {
		return new SmallUniverse(function () {
			return injector.instantiate(enthralerdotcom.templates.ManageTemplatesPage);
		}, context);
	}


	@:all('/i/$guid/edit')
	public function editContent(guid: String, context: Context) {
		return new SmallUniverse(function () {
			return injector.instantiateWith(enthralerdotcom.content.ContentEditorPage, [
				guid
			]);
		}, context);
	}


	@:all('/i/$guid')
	public function viewContent(guid: String, context: Context) {
		return new SmallUniverse(function () {
			return injector.instantiateWith(enthralerdotcom.content.ContentViewerPage, [
				guid
			]);
		}, context);
	}

	@:all('/')
	public function homepage(context: Context) {
		return new SmallUniverse(function () {
			return injector.instantiate(enthralerdotcom.homepage.HomePage);
		}, context);
	}
}
