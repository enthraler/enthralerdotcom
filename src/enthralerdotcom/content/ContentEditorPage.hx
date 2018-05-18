package enthralerdotcom.content;

import smalluniverse.UniversalPage;
import smalluniverse.SUMacro.jsx;
import enthralerdotcom.components.*;
import enthralerdotcom.types.*;
using tink.CoreApi;
import enthraler.proptypes.Validators;
import enthraler.proptypes.PropTypes;
import enthraler.EnthralerMessages;
import haxe.Json;
import haxe.Http;
import enthralerdotcom.util.Merge;
#if client
import enthralerdotcom.services.client.ErrorNotificationService;
#end

enum ContentEditorAction {
	SaveFirstAnonymousVersion(authorGuid: String, newContent: String, newTitle: String, templateId: Int, templateVersionId: Int, draft: Bool);
	SaveAnonymousVersion(contentId:Int, authorGuid:String, newContent:String, newTitle: String, templateVersionId:Int, draft:Bool);
}

typedef ContentEditorProps = {
	template:{
		id:Int,
		name:String,
		versionId:Int,
		version:String,
		mainUrl:String,
		schemaUrl:String
	},
	content:{
		id:Null<Int>,
		title:String,
		guid:Null<String>,
	},
	currentVersion:{
		versionId:Null<Int>,
		jsonContent:String,
		published:Null<Date>
	}
}

typedef ContentEditorState = {
	contentJson:String,
	contentTitle: String,
	contentData:Any,
	validationResult:Null<Array<ValidationError>>,
	schema:PropTypes
}

class ContentEditorPage extends UniversalPage<ContentEditorAction, ContentEditorProps, ContentEditorState> {

	@:client var preview:js.html.IFrameElement;
	@:client function setIframe(iframe) this.preview = iframe;

	public function new(api:ContentEditorBackendApi) {
		super(api);
		Head.prepareHead(this.head);
	}

	override public function componentWillMount() {
		Head.addOEmbedCodes(this.head, this.props.content.guid);
	}

	static function loadFromUrl(url:String):Promise<String> {
		return Future.async(function (handler:Outcome<String,Error>->Void) {
			var h = new haxe.Http(url);
			var status = null;
			h.onStatus = function (s) {
				status = s;
			}
			h.onData = function (result) {
				handler(Success(result));
			}
			h.onError = function (errMessage) {
				handler(Failure(new Error(status, errMessage)));
			}
			h.request(false);
		});
	}

	@:client
	override public function componentDidMount() {
		this.setState({
			contentJson: this.props.currentVersion.jsonContent,
			contentTitle: this.props.content.title,
			contentData: Json.parse(this.props.currentVersion.jsonContent),
			validationResult: null,
			schema: null
		});
		EnthralerHost.addMessageListeners();
		loadFromUrl(this.props.template.schemaUrl)
			.next(function (schemaJson) {
				var schema = PropTypes.fromObject(Json.parse(schemaJson));
				this.setState(Merge.object(this.state, {
					schema: schema,
				}));
				return schema;
			})
			.recover(function (err:Error):PropTypes {
				trace('Failed to load schema from URL', err);
				return null;
			})
			.handle(function () {});
	}

	override function render() {
		this.head.setTitle('Content Editor');
		if (this.state == null) {
			return jsx('<div>Loading</div>');
		}
		var iframeSrc = (props.currentVersion.versionId != null)
			? '/i/${props.content.guid}/embed/${props.currentVersion.versionId}'
			: '/i/new/${props.template.id}/embed/';
		var iframeStyle = {
			display: 'block',
			width: '960px',
			maxWidth: '100%',
			height: '350px'
		};
		var contentTitle = this.state.contentTitle;
		return jsx('<div className="container">
			<HeaderNav></HeaderNav>
			<h1 className="title"><label htmlFor="content-title">Title:</label></h1>
			<input id="content-title" defaultValue=${contentTitle} onChange=${onTitleChange} onKeyUp=${onTitleChange} className="title" />
			<h2 className="subtitle">Using template <a href=${"/templates/github/"+props.template.name}><em>${props.template.name}</em></a></h2>
			<div className="field is-grouped">
				<div className="control">
					<a className="button is-primary" onClick=${onSave.bind(false)}>Save</a>
				</div>
				<div className="control">
					<a className="button" onClick=${onSave.bind(true)}>Save Draft</a>
				</div>
			</div>
			<div className="columns">
				<div className="column editor">
					<ContentEditorForm content=${state.contentData} onChange=${onFormChange} schema=${state.schema} />
					<CodeMirrorEditor content=${state.contentJson} onChange=${onEditorChange}></CodeMirrorEditor>
				</div>
				<div className="column">
					${renderErrorList()}
					<iframe src=${iframeSrc} ref=${setIframe} id="preview" className="enthraler-embed" frameBorder="0" style=${iframeStyle}></iframe>
				</div>
			</div>
		</div>');
	}

	function renderErrorList() {
		if (state == null || state.validationResult == null) {
			return null;
		}

		var errors = [];
		function addError(err:ValidationError) {
			errors.push(jsx('<li>
				<strong>${err.getErrorPath()}</strong>: ${err.message}
			</li>'));
			for (childError in err.childErrors) {
				addError(childError);
			}
		}
		for (err in state.validationResult) {
			addError(err);
		}

		return jsx('<ul>${errors}</ul>');
	}

	@:client
	function getUserGuid():UserGuid {
		var guidString = js.Browser.window.localStorage.getItem('enthraler_anonymous_guid');
		if (guidString != null) {
			return new UserGuid(guidString);
		} else {
			var guid = UserGuid.generate();
			js.Browser.window.localStorage.setItem('enthraler_anonymous_guid', guid);
			return guid;
		}
	}

	@:client
	function onSave(draft:Bool) {
		if (state.validationResult != null) {
			ErrorNotificationService.inst.logMessage("We can't save while you have validation errors, please fix them first");
			return;
		}
		var action = props.content.id != null
			? SaveAnonymousVersion(props.content.id, getUserGuid(), state.contentJson, state.contentTitle, props.template.versionId, draft)
			: SaveFirstAnonymousVersion(getUserGuid(), state.contentJson, state.contentTitle, props.template.id, props.template.versionId, draft);
		this.trigger(action).handle(function (outcome) switch outcome {
			case Failure(err):
				ErrorNotificationService.inst.logError(err, onSave.bind(draft), 'Try Again');
			case _:
		});
	}

	@:client
	function onEditorChange(newJson:String) {
		var authorData = null;

		try {
			authorData = Json.parse(newJson);
		} catch (e:Dynamic) {
			js.Browser.console.error(e);
			this.setState(Merge.object(this.state, {
				contentJson: newJson,
				validationResult: [
					new ValidationError('JSON syntax error: ' + e, AccessProperty('document'))
				],
			}));
		}
		if (authorData != null) {
			onNewContent(authorData, newJson);
		}
	}

	@:client
	function onFormChange(authorData) {
		onNewContent(authorData, Json.stringify(authorData, null, "\t"));
	}

	@:client
	function onNewContent(authorData, newJson) {
		var validationResult = null;
		if (this.state.schema != null) {
			validationResult = Validators.validate(this.state.schema, authorData, 'live JSON editor');
		}
		if (this.state.schema != null && validationResult == null) {
			validationResult = Validators.validate(this.state.schema, authorData, 'live JSON editor');
		}
		this.setState(Merge.object(this.state, {
			contentJson: newJson,
			contentData: authorData,
			validationResult: validationResult,
		}));
	}

	@:client
	function onTitleChange(e:react.ReactEvent) {
		var target = cast (e.target, js.html.InputElement);
		this.setState(Merge.object(this.state, {
			contentTitle: target.value
		}));
	}

	@:client
	override function componentDidUpdate(_, _) {
		if (state.validationResult != null) {
			return;
		}
		var targetOrigin = Constants.jsLibBaseUrl.origin;
		preview.contentWindow.postMessage(Json.stringify({
			src: '' + js.Browser.window.location,
			context: EnthralerMessages.receiveAuthorData,
			authorData: this.state.contentData
		}), targetOrigin);
	}
}
