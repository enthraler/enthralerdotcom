package enthralerdotcom.homepage;

import smalluniverse.UniversalPage;
import smalluniverse.SUMacro.jsx;
import enthralerdotcom.components.*;
import enthralerdotcom.types.*;
using tink.CoreApi;

enum HomeAction {
	None;
}

class HomePage extends UniversalPage<HomeAction, {}, {}> {

	public function new(api:HomeBackendApi) {
		super(api);
		Head.prepareHead(this.head);
		// Note: currently we're importing this in Client.hx as for some reason Webpack is failing to import it from this location.
		// Webpack.require('./Mailchimp.css');
	}

	override function render() {
		this.head.setTitle('Enthraler');
		return jsx('<div>
			<div className="container is-fluid">
				<HeaderNav></HeaderNav>
			</div>
			<section className="hero is-fullheight is-dark">
				<div className="hero-body">
					<div className="container">
						<h1 className="title">
							Coming Soon: Enthraler
						</h1>
						<h2 className="subtitle">
							<strong>Create the perfect visualisation for your post, pitch or presentation.</strong>
						</h2>
						${renderMailChimpSignup()}
					</div>
				</div>
			</section>
			<section className="section">
				<div className="container">
					<h3 className="title">Enthral</h3>
					<h4 className="subtitle"><em>v. Capture the fascinated attention of.</em></h4>
				</div>
			</section>
			<section className="section">
				<div className="container">
					<h3 className="title">Enthraler</h3>
					<h4 className="subtitle"><em>n. An online visualisation that you can use to share your best stories and your biggest ideas with your audience.</em></h4>
				</div>
			</section>
		</div>');
		/**
		TODO:
		- An audience of 160k visitors
		- Has interacted with 17k enthralers
		- Created by 2k authors
		- And 172 designers
		**/
	}

	function renderMailChimpSignup() {
		return jsx('<div id="mc_embed_signup">
			<form action="https://enthraler.us17.list-manage.com/subscribe/post?u=1167f9187969a9d01abbcfcdc&amp;id=248f3c28d6" method="post"
				id="mc-embedded-subscribe-form" name="mc-embedded-subscribe-form" className="validate" target="_blank"
				novalidate="novalidate">
				<div id="mc_embed_signup_scroll">
					<!-- real people should not fill this in and expect good things - do not remove this or risk form bot signups-->
					<div className="field">
						<label className="label" for="mce-EMAIL">Subscribe to our mailing list to get early access</label>
						<div className="control">
							<input type="email" value="" name="EMAIL" className="input" id="mce-EMAIL" placeholder="email address" required="required" />
						</div>
					</div>
					<div style=${{
						position: 'absolute',
						left: '-5000px'
					}} aria-hidden="true">
						<input type="text" name="b_1167f9187969a9d01abbcfcdc_248f3c28d6" tabindex="-1" value="" />
					</div>
					<div className="field">
						<div className="control">
							<input type="submit" value="Subscribe" name="subscribe" id="mc-embedded-subscribe" className="button" />
						</div>
					</div>
				</div>
			</form>
		</div>');
	}
}
