//
//  LocationVC.swift
//  ShinyDex
//
//  Created by Sebastian Christiansen on 07/07/2020.
//  Copyright © 2020 Sebastian Christiansen. All rights reserved.
//

import UIKit
import WebKit

class LocationVC: UIViewController, WKNavigationDelegate
{
	var pokemon: Pokemon!
	var generation: Int!
	fileprivate let locationUrlService = LocationUrlService()

	override func viewDidLoad()
	{
        super.viewDidLoad()
		let webView = WKWebView()
		webView.navigationDelegate = self
		view = webView

		let url = URL(string: locationUrlService.getUrl(generation: generation, pokemon: pokemon))!
		webView.load(URLRequest(url: url))
    }
}
