//
//  Pokeball.swift
//  ShinyDexPrototype
//
//  Created by Sebastian Christiansen on 06/11/2019.
//  Copyright © 2019 Sebastian Christiansen. All rights reserved.
//

import Foundation
import UIKit

class Pokeball {
	var image: UIImage
	var name: String
	
	init(ballName: String) {
		image = UIImage(named: ballName)!
		name = ballName.capitalizingFirstLetter()
	}
}
