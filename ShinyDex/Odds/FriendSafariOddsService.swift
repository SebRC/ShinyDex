//
//  FriendSafariOddsService.swift
//  ShinyDex
//
//  Created by Sebastian Christiansen on 03/07/2020.
//  Copyright © 2020 Sebastian Christiansen. All rights reserved.
//

import Foundation

class FriendSafariOddsService {
	func getOdds(isShinyCharmActive: Bool) -> Int {
		return isShinyCharmActive ? 585 : 819
	}
}
