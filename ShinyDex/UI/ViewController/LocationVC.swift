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
	fileprivate let textResolver = TextResolver()

	override func viewDidLoad()
	{
        super.viewDidLoad()
		let webView = WKWebView()
		webView.navigationDelegate = self
		view = webView

		let isShtml = generation != 5

		var numberPrefix = ""

		if pokemon.number < 10
		{
			numberPrefix = "00"
		}
		else if pokemon.number > 9 && pokemon.number < 100
		{
			numberPrefix = "0"
		}

		numberPrefix += String(pokemon.number + 1)

		let stringUrl = "https://serebii.net/pokedex-\(textResolver.getUrl(generation: generation))/\(generation == 5 ? pokemon.name.lowercased() : numberPrefix)\(isShtml ? ".shtml" : "")"

		print(stringUrl)

		let url = URL(string: stringUrl)!
		webView.load(URLRequest(url: url))
    }
}
