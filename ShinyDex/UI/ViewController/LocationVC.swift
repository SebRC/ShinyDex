import UIKit
import WebKit

class LocationVC: UIViewController, WKNavigationDelegate {
	var pokemon: Pokemon!
	var webView: WKWebView?
	fileprivate let locationUrlService = LocationUrlService()

	override func viewDidLoad() {
        super.viewDidLoad()
		webView = WKWebView()
		webView!.navigationDelegate = self
		view = webView

		navigationItem.rightBarButtonItems = [
			UIBarButtonItem(image: UIImage(systemName: "chevron.right.circle.fill"), style: .plain, target: self, action: #selector(goForward)),
			UIBarButtonItem(image: UIImage(systemName: "chevron.left.circle.fill"), style: .plain, target: self, action: #selector(goBack))
		]

		let url = URL(string: locationUrlService.getUrl(pokemon: pokemon))!
		webView!.load(URLRequest(url: url))
    }

	@objc fileprivate func goBack() {
		if (webView!.canGoBack) {
			webView!.goBack()
		}
	}

	@objc fileprivate func goForward() {
		if (webView!.canGoForward) {
			webView!.goForward()
		}
	}
}
