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
	override func viewDidLoad()
	{
        super.viewDidLoad()
		let webView = WKWebView()
		webView.navigationDelegate = self
		view = webView

		let url = URL(string: "https://serebii.net")!
		webView.load(URLRequest(url: url))

    }
}
