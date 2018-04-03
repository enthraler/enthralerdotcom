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
import js.html.*;
import js.Browser.window;
import js.Browser.document;
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
	embedUrl:String,
}

typedef ContentViewerState = {
	iframeWidth: Int,
	iframeHeight: Int,
}

class ContentViewerPage extends UniversalPage<ContentViewerAction, ContentViewerProps, ContentViewerState> {

	@:client var iframe: IFrameElement;

	public function new(api:ContentViewerBackendApi) {
		super(api);
		Head.prepareHead(this.head);
		this.state = {
			iframeWidth: 800,
			iframeHeight: 350,
		}
	}

	override public function componentWillMount() {
		Head.addOEmbedCodes(this.head, this.props.guid);
		#if client
		EnthralerHost.addMessageListeners();
		#end
	}

	@:client
	override public function componentDidMount() {
		updateHeightOfEmbedCode();
		// We're hackily assuming any message posted from the iframe is likely changing the height.
		window.addEventListener('message', function (e:MessageEvent) {
			updateHeightOfEmbedCode();
		});
	}

	@:client
	function updateHeightOfEmbedCode() {
		var iframe = document.querySelector('.enthraler-embed');
		if (iframe != null) {
			// Wait 100ms for the height to update, then update our embed code.
			js.Browser.window.setTimeout(function () {
				var computedStyle = window.getComputedStyle(iframe);
				this.setState(Merge.object(this.state, {
					iframeHeight: Std.parseInt(computedStyle.height),
				}));
			}, 100);
		}
	}

	@:client
	function updatePreferredWidth(e:react.ReactEvent) {
		var target = cast (e.target, js.html.InputElement);
		this.setState(Merge.object(this.state, {
			iframeWidth: Std.parseInt(target.value)
		}));
	}

	override function render() {
		this.head.setTitle('Content Editor');
		var iframeSrc = (props.contentVersionId != null)
			? '/i/${props.guid}/embed/'
			: 'about:blank';
		var iframeStyle = {
			display: 'block',
			width: state.iframeWidth + 'px',
			maxWidth: '100%',
			height: state.iframeHeight + 'px'
		};
		var embedCode = getEmbedCode(iframeStyle);
		var embed = {
			__html: embedCode
		};
		return jsx('<div className="container is-fluid">
			<HeaderNav></HeaderNav>
			<h1 className="title">${props.title}</h1>
			<h2 className="subtitle">Published ${props.published.toString()} using the <a href=${"/templates/github/"+props.templateName}><em>${props.templateName} template.</em></a></h2>
			<div id="preview" dangerouslySetInnerHTML=${embed}></div>
			<div className="field">
				<label htmlFor="embed-code">Embed code:</label>
				<p className="control has-icons-left">
					<textarea id="embed-code" className="textarea" readonly="readonly" placeholder="Loading textarea" value=${embedCode}></textarea>
				</p>
			</div>
			<div className="field">
				<label htmlFor="embed-width">Preferred width:</label>
				<p className="control has-icons-left">
					<input type="number" min="0" max="10000" id="embed-width" defaultValue=${state.iframeWidth} onChange=${updatePreferredWidth} />
				</p>
			</div>
		</div>');
	}

	function getEmbedCode(style) {
		return '<iframe src="${props.embedUrl}" class="enthraler-embed" frameBorder="0" style="display: ${style.display}; width: ${style.width}; maxWidth: ${style.maxWidth}; height: ${style.height};"></iframe>';
	}
}
