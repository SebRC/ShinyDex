//
//  Gen8OddsService.swift
//  ShinyDex
//
//  Created by Sebastian Christiansen on 28/02/2020.
//  Copyright © 2020 Sebastian Christiansen. All rights reserved.
//

import Foundation

class Gen8OddsService
{
	fileprivate var isShinyCharmActive = false

	func getOdds(battles: Int, isCharmActive: Bool) -> Int
	{
		isShinyCharmActive = isCharmActive

		if battles < 50
		{
			return getTier6Odds()
		}
		else if battles >= 50 && battles < 100
		{
			return getTier5Odds()
		}
		else if battles >= 100 && battles < 200
		{
			return getTier4Odds()
		}
		else if battles >= 200 && battles < 300
		{
			return getTier3Odds()
		}
		else if battles >= 300 && battles < 500
		{
			return getTier2Odds()
		}
		return getTier1Odds()
	}

	fileprivate func getTier6Odds() -> Int
	{
		return isShinyCharmActive ? 1365 : 4096
	}

	fileprivate func getTier5Odds() -> Int
	{
		return isShinyCharmActive ? 1024 : 2048
	}

	fileprivate func getTier4Odds() -> Int
	{
		return isShinyCharmActive ? 819 : 1365
	}

	fileprivate func getTier3Odds() -> Int
	{
		return isShinyCharmActive ? 683 : 1024
	}

	fileprivate func getTier2Odds() -> Int
	{
		return isShinyCharmActive ? 585 : 819
	}

	fileprivate func getTier1Odds() -> Int
	{
		return isShinyCharmActive ? 512 : 683
	}
}
