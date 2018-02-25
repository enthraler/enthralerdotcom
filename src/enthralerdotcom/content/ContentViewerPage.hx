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
#if client
import enthralerdotcom.services.client.ErrorNotificationService;
#end

enum ContentViewerAction {
	CreateACopy(contentId:Int);
}

typedef ContentViewerProps = {
	contentVersionId:Int,
	templateName:String,
	templateUrl:String,
	contentUrl:String,
	title:String,
	published:Date,
	guid:String,
	embedCode:String,
}

typedef ContentViewerState = {}

class ContentViewerPage extends UniversalPage<ContentViewerAction, ContentViewerProps, ContentViewerState> {

	public function new(api:ContentViewerBackendApi) {
		super(api);
	}

	override public function componentWillMount() {
		Head.prepareHead(this.head, this.props.guid);
	}

	@:client
	override public function componentDidMount() {
		EnthralerHost.addMessageListeners();
	}

	override function render() {
		this.head.setTitle('Content Editor');
		var iframeSrc = (props.contentVersionId != null)
			? '/i/${props.guid}/embed/'
			: 'about:blank';
		var iframeStyle = {
			display: 'block',
			width: '100%',
			maxWidth: '100%',
			height: '350px'
		};
		return jsx('<div className="container is-fluid">
			<HeaderNav></HeaderNav>
			<h1 className="title">${props.title}</h1>
			<h2 className="subtitle">Published ${props.published.toString()} using the <a href=${"/templates/github/"+props.templateName}><em>${props.templateName} template.</em></a></h2>
			<h2 className="subtitle"></h2>
			<iframe src=${iframeSrc} id="preview" className="enthraler-embed" frameBorder="0" style=${iframeStyle}></iframe>
			<div class="field">
				<p class="control has-icons-left">
					<textarea class="textarea" placeholder="Loading textarea">${props.embedCode}</textarea>
				</p>
			</div>
		</div>');
	}
}
