//
//  Game.swift
//  ShinyDex
//
//  Created by Sebastian Christiansen on 19/07/2022.
//  Copyright © 2022 Sebastian Christiansen. All rights reserved.
//

import Foundation

class Game {
    var title: String
    var coverPokemon: String
    var generation: Int
    
    init(title: String, coverPokemon: String, generation: Int) {
        self.title = title
        self.coverPokemon = coverPokemon
        self.generation = generation
    }
}
