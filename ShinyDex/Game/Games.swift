//
//  Games.swift
//  ShinyDex
//
//  Created by Sebastian Christiansen on 19/07/2022.
//  Copyright © 2022 Sebastian Christiansen. All rights reserved.
//

import Foundation

enum Games: String {
    case Red = "Red"
    case Blue = "Blue"
    case Yellow = "Yellow"
    case Gold = "Gold"
    case Silver = "Silver"
    case Crystal = "Crystal"
    case Ruby = "Ruby"
    case Sapphire = "Sapphire"
    case Emerald = "Emerald"
    case FireRed = "Fire Red"
    case LeafGreen = "Leaf Green"
    case Diamond = "Diamond"
    case Pearl = "pearl"
    case Platinum = "Platinum"
    case Heartgold = "Heartgold"
    case SoulSilver = "SoulSilver"
    case Black = "Black"
    case White = "White"
    case Black2 = "Black 2"
    case White2 = "White 2"
    case X = "X"
    case Y = "Y"
    case OmegaRuby = "Omega Ruby"
    case AlphaSapphire = "Alpha Sapphire"
    case Sun = "Sun"
    case Moon = "Moon"
    case UltraSun = "Ultra Sun"
    case UltraMoon = "Ultra Moon"
    case LetsGoPikachu = "Let's Go Pikachu"
    case LetsGoEevee = "Let's Go Eevee"
    case Sword = "Sword"
    case Shield = "Shield"
}

 class GamesList {
     static var games = [Games.Red: Game(title: Games.Red.rawValue, coverPokemon: "charizard", generation: 1),
                         Games.Blue: Game(title: Games.Blue.rawValue, coverPokemon: "blastoise", generation: 1),
                         Games.Yellow: Game(title: Games.Yellow.rawValue, coverPokemon: "pikachu", generation: 1),
                         Games.Gold: Game(title: Games.Gold.rawValue, coverPokemon: "ho-oh", generation: 2),
                         Games.Silver: Game(title: Games.Silver.rawValue, coverPokemon: "lugia", generation: 2),
                         Games.Crystal: Game(title: Games.Crystal.rawValue, coverPokemon: "suicune", generation: 2),
                         Games.Ruby: Game(title: Games.Ruby.rawValue, coverPokemon: "groudon", generation: 3),
                         Games.Sapphire: Game(title: Games.Sapphire.rawValue, coverPokemon: "kyogre", generation: 3),
                         Games.Emerald: Game(title: Games.Emerald.rawValue, coverPokemon: "rayquaza", generation: 3),
                         Games.FireRed: Game(title: Games.FireRed.rawValue, coverPokemon: "charizard", generation: 3),
                         Games.LeafGreen: Game(title: Games.LeafGreen.rawValue, coverPokemon: "venusaur", generation: 3),
                         Games.Diamond: Game(title: Games.Diamond.rawValue, coverPokemon: "dialga", generation: 4),
                         Games.Pearl: Game(title: Games.Pearl.rawValue, coverPokemon: "palkia", generation: 4),
                         Games.Platinum: Game(title: Games.Platinum.rawValue, coverPokemon: "giratina", generation: 4),
                         Games.Heartgold: Game(title: Games.Heartgold.rawValue, coverPokemon: "ho-oh", generation: 4),
                         Games.SoulSilver: Game(title: Games.SoulSilver.rawValue, coverPokemon: "lugia", generation: 4),
                         Games.Black: Game(title: Games.Black.rawValue, coverPokemon: "reshiram", generation: 5),
                         Games.White: Game(title: Games.White.rawValue, coverPokemon: "zekrom", generation: 5),
                         Games.Black2: Game(title: Games.Black2.rawValue, coverPokemon: "kyurem", generation: 5),
                         Games.White2: Game(title: Games.White2.rawValue, coverPokemon: "kyurem", generation: 5),
                         Games.X: Game(title: Games.X.rawValue, coverPokemon: "xerneas", generation: 6),
                         Games.Y: Game(title: Games.Y.rawValue, coverPokemon: "yveltal", generation: 6),
                         Games.OmegaRuby: Game(title: Games.OmegaRuby.rawValue, coverPokemon: "groudon", generation: 6),
                         Games.AlphaSapphire: Game(title: Games.AlphaSapphire.rawValue, coverPokemon: "kyogre", generation: 6),
                         Games.Sun: Game(title: Games.Sun.rawValue, coverPokemon: "solgaleo", generation: 7),
                         Games.Moon: Game(title: Games.Moon.rawValue, coverPokemon: "lunala", generation: 7),
                         Games.UltraSun: Game(title: Games.UltraSun.rawValue, coverPokemon: "solgaleo", generation: 7),
                         Games.UltraMoon: Game(title: Games.UltraMoon.rawValue, coverPokemon: "lunala", generation: 7),
                         Games.LetsGoPikachu: Game(title: Games.LetsGoPikachu.rawValue, coverPokemon: "pikachu", generation: 7),
                         Games.LetsGoEevee: Game(title: Games.LetsGoEevee.rawValue, coverPokemon: "eevee", generation: 7),
                         Games.Sword: Game(title: Games.Sword.rawValue, coverPokemon: "zacian", generation: 8),
                         Games.Shield: Game(title: Games.Shield.rawValue, coverPokemon: "zamazenta", generation: 8),]
}
