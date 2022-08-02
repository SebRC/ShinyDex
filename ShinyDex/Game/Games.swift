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
    case FireRed = "FireRed"
    case LeafGreen = "LeafGreen"
    case Diamond = "Diamond"
    case Pearl = "pearl"
    case Platinum = "Platinum"
    case Heartgold = "HeartGold"
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
     static var games : [Games: Game] = [.Red: Game(title: Games.Red.rawValue, coverPokemon: "charizard-game-icon", generation: 1, availableMethods: [.Encounters], isShinyCharmAvailable: false),
                         .Blue: Game(title: Games.Blue.rawValue, coverPokemon: "blastoise-game-icon", generation: 1, availableMethods: [.Encounters], isShinyCharmAvailable: false),
                         .Yellow: Game(title: Games.Yellow.rawValue, coverPokemon: "pikachu-game-icon", generation: 1, availableMethods: [.Encounters], isShinyCharmAvailable: false),
                         .Gold: Game(title: Games.Gold.rawValue, coverPokemon: "ho-oh-game-icon", generation: 2, availableMethods: [.Encounters, .Gen2Breeding], isShinyCharmAvailable: false),
                         .Silver: Game(title: Games.Silver.rawValue, coverPokemon: "lugia-game-icon", generation: 2, availableMethods: [.Encounters, .Gen2Breeding], isShinyCharmAvailable: false),
                         .Crystal: Game(title: Games.Crystal.rawValue, coverPokemon: "suicune-game-icon", generation: 2, availableMethods: [.Encounters, .Gen2Breeding], isShinyCharmAvailable: false),
                         .Ruby: Game(title: Games.Ruby.rawValue, coverPokemon: "groudon-game-icon", generation: 3, availableMethods: [.Encounters], isShinyCharmAvailable: false),
                         .Sapphire: Game(title: Games.Sapphire.rawValue, coverPokemon: "kyogre-game-icon", generation: 3, availableMethods: [.Encounters], isShinyCharmAvailable: false),
                         .Emerald: Game(title: Games.Emerald.rawValue, coverPokemon: "rayquaza-game-icon", generation: 3, availableMethods: [.Encounters], isShinyCharmAvailable: false),
                         .FireRed: Game(title: Games.FireRed.rawValue, coverPokemon: "charizard-game-icon", generation: 3, availableMethods: [.Encounters], isShinyCharmAvailable: false),
                         .LeafGreen: Game(title: Games.LeafGreen.rawValue, coverPokemon: "venusaur-game-icon", generation: 3, availableMethods: [.Encounters], isShinyCharmAvailable: false),
                         .Diamond: Game(title: Games.Diamond.rawValue, coverPokemon: "dialga-game-icon", generation: 4, availableMethods: [.Encounters, .Masuda, .Pokeradar], isShinyCharmAvailable: false),
                         .Pearl: Game(title: Games.Pearl.rawValue, coverPokemon: "palkia-game-icon", generation: 4, availableMethods: [.Encounters, .Masuda, .Pokeradar], isShinyCharmAvailable: false),
                         .Platinum: Game(title: Games.Platinum.rawValue, coverPokemon: "giratina-game-icon", generation: 4, availableMethods: [.Encounters, .Masuda, .Pokeradar], isShinyCharmAvailable: false),
                         .Heartgold: Game(title: Games.Heartgold.rawValue, coverPokemon: "ho-oh-game-icon", generation: 4, availableMethods: [.Encounters, .Masuda], isShinyCharmAvailable: false),
                         .SoulSilver: Game(title: Games.SoulSilver.rawValue, coverPokemon: "lugia-game-icon", generation: 4, availableMethods: [.Encounters, .Masuda], isShinyCharmAvailable: false),
                         .Black: Game(title: Games.Black.rawValue, coverPokemon: "reshiram-game-icon", generation: 5, availableMethods: [.Encounters, .Masuda], isShinyCharmAvailable: false),
                         .White: Game(title: Games.White.rawValue, coverPokemon: "zekrom-game-icon", generation: 5, availableMethods: [.Encounters, .Masuda], isShinyCharmAvailable: false),
                         .Black2: Game(title: Games.Black2.rawValue, coverPokemon: "kyurem-black-game-icon", generation: 5, availableMethods: [.Encounters, .Masuda], isShinyCharmAvailable: true),
                         .White2: Game(title: Games.White2.rawValue, coverPokemon: "kyurem-white-game-icon", generation: 5, availableMethods: [.Encounters, .Masuda], isShinyCharmAvailable: true),
                         .X: Game(title: Games.X.rawValue, coverPokemon: "xerneas-game-icon", generation: 6, availableMethods: [.Encounters, .Masuda, .Pokeradar, .ChainFishing, .FriendSafari], isShinyCharmAvailable: true),
                         .Y: Game(title: Games.Y.rawValue, coverPokemon: "yveltal-game-icon", generation: 6, availableMethods: [.Encounters, .Masuda, .Pokeradar, .ChainFishing, .FriendSafari], isShinyCharmAvailable: true),
                         .OmegaRuby: Game(title: Games.OmegaRuby.rawValue, coverPokemon: "groudon-primal-game-icon", generation: 6, availableMethods: [.Encounters, .Masuda, .ChainFishing, .DexNav], isShinyCharmAvailable: true),
                         .AlphaSapphire: Game(title: Games.AlphaSapphire.rawValue, coverPokemon: "kyogre-primal-game-icon", generation: 6, availableMethods: [.Encounters, .Masuda, .ChainFishing, .DexNav], isShinyCharmAvailable: true),
                         .Sun: Game(title: Games.Sun.rawValue, coverPokemon: "solgaleo-game-icon", generation: 7, availableMethods: [.Encounters, .Masuda, .SosChaining], isShinyCharmAvailable: true),
                         .Moon: Game(title: Games.Moon.rawValue, coverPokemon: "lunala-game-icon", generation: 7, availableMethods: [.Encounters, .Masuda, .SosChaining], isShinyCharmAvailable: true),
                         .UltraSun: Game(title: Games.UltraSun.rawValue, coverPokemon: "necrozma-dusk-game-icon", generation: 7, availableMethods: [.Encounters, .Masuda, .SosChaining], isShinyCharmAvailable: true),
                         .UltraMoon: Game(title: Games.UltraMoon.rawValue, coverPokemon: "necrozma-dawn-game-icon", generation: 7, availableMethods: [.Encounters, .Masuda, .SosChaining], isShinyCharmAvailable: true),
                         .LetsGoPikachu: Game(title: Games.LetsGoPikachu.rawValue, coverPokemon: "pikachu-starter-game-icon", generation: 7, availableMethods: [.Encounters, .Lure], isShinyCharmAvailable: true),
                         .LetsGoEevee: Game(title: Games.LetsGoEevee.rawValue, coverPokemon: "eevee-starter-game-icon", generation: 7, availableMethods: [.Encounters, .Lure], isShinyCharmAvailable: true),
                         .Sword: Game(title: Games.Sword.rawValue, coverPokemon: "zacian-game-icon", generation: 8, availableMethods: [.Encounters, .Masuda], isShinyCharmAvailable: true),
                         .Shield: Game(title: Games.Shield.rawValue, coverPokemon: "zamazenta-game-icon", generation: 8, availableMethods: [.Encounters, .Masuda], isShinyCharmAvailable: true),]
}
