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

var enabledMethods = [
                      5: [HuntMethod.Encounters, HuntMethod.Masuda],
                      5: [HuntMethod.Encounters, HuntMethod.Masuda],
                      5: [HuntMethod.Encounters, HuntMethod.Masuda],
                      6: [HuntMethod.Encounters, HuntMethod.Masuda, HuntMethod.Pokeradar, HuntMethod.ChainFishing, HuntMethod.DexNav, HuntMethod.FriendSafari],
                      7: [HuntMethod.Encounters, HuntMethod.Masuda, HuntMethod.SosChaining, HuntMethod.Lure],
                      8: [HuntMethod.Encounters, HuntMethod.Masuda]]

 class GamesList {
     static var games = [Games.Red: Game(title: Games.Red.rawValue, coverPokemon: "charizard", generation: 1, availableMethods: [HuntMethod.Encounters], isShinyCharmAvailable: false),
                         Games.Blue: Game(title: Games.Blue.rawValue, coverPokemon: "blastoise", generation: 1, availableMethods: [HuntMethod.Encounters], isShinyCharmAvailable: false),
                         Games.Yellow: Game(title: Games.Yellow.rawValue, coverPokemon: "pikachu", generation: 1, availableMethods: [HuntMethod.Encounters], isShinyCharmAvailable: false),
                         Games.Gold: Game(title: Games.Gold.rawValue, coverPokemon: "ho-oh", generation: 2, availableMethods: [HuntMethod.Encounters, HuntMethod.Gen2Breeding], isShinyCharmAvailable: false),
                         Games.Silver: Game(title: Games.Silver.rawValue, coverPokemon: "lugia", generation: 2, availableMethods: [HuntMethod.Encounters, HuntMethod.Gen2Breeding], isShinyCharmAvailable: false),
                         Games.Crystal: Game(title: Games.Crystal.rawValue, coverPokemon: "suicune", generation: 2, availableMethods: [HuntMethod.Encounters, HuntMethod.Gen2Breeding], isShinyCharmAvailable: false),
                         Games.Ruby: Game(title: Games.Ruby.rawValue, coverPokemon: "groudon", generation: 3, availableMethods: [HuntMethod.Encounters], isShinyCharmAvailable: false),
                         Games.Sapphire: Game(title: Games.Sapphire.rawValue, coverPokemon: "kyogre", generation: 3, availableMethods: [HuntMethod.Encounters], isShinyCharmAvailable: false),
                         Games.Emerald: Game(title: Games.Emerald.rawValue, coverPokemon: "rayquaza", generation: 3, availableMethods: [HuntMethod.Encounters], isShinyCharmAvailable: false),
                         Games.FireRed: Game(title: Games.FireRed.rawValue, coverPokemon: "charizard", generation: 3, availableMethods: [HuntMethod.Encounters], isShinyCharmAvailable: false),
                         Games.LeafGreen: Game(title: Games.LeafGreen.rawValue, coverPokemon: "venusaur", generation: 3, availableMethods: [HuntMethod.Encounters], isShinyCharmAvailable: false),
                         Games.Diamond: Game(title: Games.Diamond.rawValue, coverPokemon: "dialga", generation: 4, availableMethods: [HuntMethod.Encounters, HuntMethod.Masuda, HuntMethod.Pokeradar], isShinyCharmAvailable: false),
                         Games.Pearl: Game(title: Games.Pearl.rawValue, coverPokemon: "palkia", generation: 4, availableMethods: [HuntMethod.Encounters, HuntMethod.Masuda, HuntMethod.Pokeradar], isShinyCharmAvailable: false),
                         Games.Platinum: Game(title: Games.Platinum.rawValue, coverPokemon: "giratina", generation: 4, availableMethods: [HuntMethod.Encounters, HuntMethod.Masuda, HuntMethod.Pokeradar], isShinyCharmAvailable: false),
                         Games.Heartgold: Game(title: Games.Heartgold.rawValue, coverPokemon: "ho-oh", generation: 4, availableMethods: [HuntMethod.Encounters, HuntMethod.Masuda], isShinyCharmAvailable: false),
                         Games.SoulSilver: Game(title: Games.SoulSilver.rawValue, coverPokemon: "lugia", generation: 4, availableMethods: [HuntMethod.Encounters, HuntMethod.Masuda], isShinyCharmAvailable: false),
                         Games.Black: Game(title: Games.Black.rawValue, coverPokemon: "reshiram", generation: 5, availableMethods: [HuntMethod.Encounters, HuntMethod.Masuda], isShinyCharmAvailable: false),
                         Games.White: Game(title: Games.White.rawValue, coverPokemon: "zekrom", generation: 5, availableMethods: [HuntMethod.Encounters, HuntMethod.Masuda], isShinyCharmAvailable: false),
                         Games.Black2: Game(title: Games.Black2.rawValue, coverPokemon: "kyurem", generation: 5, availableMethods: [HuntMethod.Encounters, HuntMethod.Masuda], isShinyCharmAvailable: true),
                         Games.White2: Game(title: Games.White2.rawValue, coverPokemon: "kyurem", generation: 5, availableMethods: [HuntMethod.Encounters, HuntMethod.Masuda], isShinyCharmAvailable: true),
                         Games.X: Game(title: Games.X.rawValue, coverPokemon: "xerneas", generation: 6, availableMethods: [HuntMethod.Encounters, HuntMethod.Masuda, HuntMethod.Pokeradar, HuntMethod.ChainFishing, HuntMethod.FriendSafari], isShinyCharmAvailable: true),
                         Games.Y: Game(title: Games.Y.rawValue, coverPokemon: "yveltal", generation: 6, availableMethods: [HuntMethod.Encounters, HuntMethod.Masuda, HuntMethod.Pokeradar, HuntMethod.ChainFishing, HuntMethod.FriendSafari], isShinyCharmAvailable: true),
                         Games.OmegaRuby: Game(title: Games.OmegaRuby.rawValue, coverPokemon: "groudon", generation: 6, availableMethods: [HuntMethod.Encounters, HuntMethod.Masuda, HuntMethod.ChainFishing, HuntMethod.DexNav], isShinyCharmAvailable: true),
                         Games.AlphaSapphire: Game(title: Games.AlphaSapphire.rawValue, coverPokemon: "kyogre", generation: 6, availableMethods: [HuntMethod.Encounters, HuntMethod.Masuda, HuntMethod.ChainFishing, HuntMethod.DexNav], isShinyCharmAvailable: true),
                         Games.Sun: Game(title: Games.Sun.rawValue, coverPokemon: "solgaleo", generation: 7, availableMethods: [HuntMethod.Encounters, HuntMethod.Masuda, HuntMethod.SosChaining], isShinyCharmAvailable: true),
                         Games.Moon: Game(title: Games.Moon.rawValue, coverPokemon: "lunala", generation: 7, availableMethods: [HuntMethod.Encounters, HuntMethod.Masuda, HuntMethod.SosChaining], isShinyCharmAvailable: true),
                         Games.UltraSun: Game(title: Games.UltraSun.rawValue, coverPokemon: "solgaleo", generation: 7, availableMethods: [HuntMethod.Encounters, HuntMethod.Masuda, HuntMethod.SosChaining], isShinyCharmAvailable: true),
                         Games.UltraMoon: Game(title: Games.UltraMoon.rawValue, coverPokemon: "lunala", generation: 7, availableMethods: [HuntMethod.Encounters, HuntMethod.Masuda, HuntMethod.SosChaining], isShinyCharmAvailable: true),
                         Games.LetsGoPikachu: Game(title: Games.LetsGoPikachu.rawValue, coverPokemon: "pikachu", generation: 7, availableMethods: [HuntMethod.Encounters, HuntMethod.Lure], isShinyCharmAvailable: true),
                         Games.LetsGoEevee: Game(title: Games.LetsGoEevee.rawValue, coverPokemon: "eevee", generation: 7, availableMethods: [HuntMethod.Encounters, HuntMethod.Lure], isShinyCharmAvailable: true),
                         Games.Sword: Game(title: Games.Sword.rawValue, coverPokemon: "zacian", generation: 8, availableMethods: [HuntMethod.Encounters, HuntMethod.Masuda], isShinyCharmAvailable: true),
                         Games.Shield: Game(title: Games.Shield.rawValue, coverPokemon: "zamazenta", generation: 8, availableMethods: [HuntMethod.Encounters, HuntMethod.Masuda], isShinyCharmAvailable: true),]
}
