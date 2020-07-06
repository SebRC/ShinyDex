//
//  DexNavOddsService.swift
//  ShinyDex
//
//  Created by Sebastian Christiansen on 06/07/2020.
//  Copyright © 2020 Sebastian Christiansen. All rights reserved.
//

import Foundation

class DexNavOddsService
{
	func getOdds(searchLevel: Int, isShinyCharmActive: Bool) -> Int
	{
		let withBonus = calculateDexNavProbability(randomBonus: true, searchLevel: searchLevel, isShinyCharmActive: isShinyCharmActive);
		let withoutBonus = calculateDexNavProbability(randomBonus: false, searchLevel: searchLevel, isShinyCharmActive: isShinyCharmActive);

		let totalProbability = 0.04 * withBonus + 0.96 * withoutBonus;
		let odds = round(1.0/totalProbability);
		return Int(odds)
	}

	fileprivate func calculateDexNavProbability(randomBonus: Bool, searchLevel: Int, isShinyCharmActive: Bool) -> Double
	{
		var counter = searchLevel
		var d0 = 0.0;
		if(counter > 200)
		{
			d0 += Double(counter) - 200.0;
			counter = 200;
		}

		if(counter > 100)
		{
			d0 += Double((counter * 2)) - 200.0;
			counter = 100;
		}

		if(counter > 0)
		{
			d0 += Double(counter) * 6.0;
		}

		let d8 = ceil(d0 * 0.01);
		//since the random generated number is an integer and not a floating-point number
		//we have to round up the d8 value to get the good probability
		//example :  if d8=12.18, the pokemon is shiny only if random_num<12.18
		//           but random_num is an integer so the pokemon is shiny if random_num<13
		//           so the probability is 13/10000 (13 possible values for random_num that are less than 13) (10000 is the number of possible values for random_num)

		var recompute = 1 + (isShinyCharmActive ? 2 : 0) + (randomBonus ? 4 : 0);

		//Probability to get at least 1 shiny value during dexnav pokemon generation
		//Binomial law n = recompute and p = d8 / 10000
		//P(X >= 1) = 1 - P(X = 0)
		//P(X = 0) = pow(1 - p, n)
		//P(X >= 1) = 1 - pow(1 - p, n)
		let dexNavProbability = 1.0 - pow((1.0 - (d8 / 10000)), Double(recompute));


		recompute = (isShinyCharmActive ? 3 : 1);

		//Probability to get a shiny PID during PID generation
		//Truncated geometric distribution => stop when a success happen => loop broken when we got shiny PID
		//with n = recompute and p = 1/4096 the proba to get a shiny PID
		//P(X = 0) = pow(1 - p, n) // proba that the event does not occur before n tries
		//P(X >= 1) = 1 - P(X = 0)
		//P(X >= 1) = 1 - pow(1 - p, n)
		let shinyPIDProbability = 1.0 - pow(1.0 - (1.0 / 4096), Double(recompute)) as Double;

		//event D : shiny boolean value during dexnav gen
		//event S : shiny PID
		//If D is realized then S too
		//If not D then the proba that S is realized is shinyPID_proba
		//So we have P(S) = P(not D cross S) + P(D cross S)
		//with P(not D cross S) = (1.0 - dexnav_proba) * shinyPID_proba
		//and P(D cross S) = dexnav_proba * 1
		let totalProbability = ((1.0 - dexNavProbability) * shinyPIDProbability as Double) + (dexNavProbability * 1);

		return totalProbability;
	}
}
