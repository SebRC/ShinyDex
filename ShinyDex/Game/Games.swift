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
    case LegendsArceus = "Legends: Arceus"
    case Scarlet = "Scarlet"
    case Violet = "Violet"
}

 class GamesList {
     static var games : [Games: Game] = [.Red: Game(game: Games.Red, coverPokemon: "charizard-game-icon", generation: 1, availableMethods: [.Encounters], isShinyCharmAvailable: false),
                         .Blue: Game(game: Games.Blue, coverPokemon: "blastoise-game-icon", generation: 1, availableMethods: [.Encounters], isShinyCharmAvailable: false),
                         .Yellow: Game(game: Games.Yellow, coverPokemon: "pikachu-game-icon", generation: 1, availableMethods: [.Encounters], isShinyCharmAvailable: false),
                         .Gold: Game(game: Games.Gold, coverPokemon: "ho-oh-game-icon", generation: 2, availableMethods: [.Encounters, .Gen2Breeding], isShinyCharmAvailable: false),
                         .Silver: Game(game: Games.Silver, coverPokemon: "lugia-game-icon", generation: 2, availableMethods: [.Encounters, .Gen2Breeding], isShinyCharmAvailable: false),
                         .Crystal: Game(game: Games.Crystal, coverPokemon: "suicune-game-icon", generation: 2, availableMethods: [.Encounters, .Gen2Breeding], isShinyCharmAvailable: false),
                         .Ruby: Game(game: Games.Ruby, coverPokemon: "groudon-game-icon", generation: 3, availableMethods: [.Encounters], isShinyCharmAvailable: false),
                         .Sapphire: Game(game: Games.Sapphire, coverPokemon: "kyogre-game-icon", generation: 3, availableMethods: [.Encounters], isShinyCharmAvailable: false),
                         .Emerald: Game(game: Games.Emerald, coverPokemon: "rayquaza-game-icon", generation: 3, availableMethods: [.Encounters], isShinyCharmAvailable: false),
                         .FireRed: Game(game: Games.FireRed, coverPokemon: "charizard-game-icon", generation: 3, availableMethods: [.Encounters], isShinyCharmAvailable: false),
                         .LeafGreen: Game(game: Games.LeafGreen, coverPokemon: "venusaur-game-icon", generation: 3, availableMethods: [.Encounters], isShinyCharmAvailable: false),
                         .Diamond: Game(game: Games.Diamond, coverPokemon: "dialga-game-icon", generation: 4, availableMethods: [.Encounters, .Masuda, .Pokeradar], isShinyCharmAvailable: false),
                         .Pearl: Game(game: Games.Pearl, coverPokemon: "palkia-game-icon", generation: 4, availableMethods: [.Encounters, .Masuda, .Pokeradar], isShinyCharmAvailable: false),
                         .Platinum: Game(game: Games.Platinum, coverPokemon: "giratina-game-icon", generation: 4, availableMethods: [.Encounters, .Masuda, .Pokeradar], isShinyCharmAvailable: false),
                         .Heartgold: Game(game: Games.Heartgold, coverPokemon: "ho-oh-game-icon", generation: 4, availableMethods: [.Encounters, .Masuda], isShinyCharmAvailable: false),
                         .SoulSilver: Game(game: Games.SoulSilver, coverPokemon: "lugia-game-icon", generation: 4, availableMethods: [.Encounters, .Masuda], isShinyCharmAvailable: false),
                         .Black: Game(game: Games.Black, coverPokemon: "reshiram-game-icon", generation: 5, availableMethods: [.Encounters, .Masuda], isShinyCharmAvailable: false),
                         .White: Game(game: Games.White, coverPokemon: "zekrom-game-icon", generation: 5, availableMethods: [.Encounters, .Masuda], isShinyCharmAvailable: false),
                         .Black2: Game(game: Games.Black2, coverPokemon: "kyurem-black-game-icon", generation: 5, availableMethods: [.Encounters, .Masuda], isShinyCharmAvailable: true),
                         .White2: Game(game: Games.White2, coverPokemon: "kyurem-white-game-icon", generation: 5, availableMethods: [.Encounters, .Masuda], isShinyCharmAvailable: true),
                         .X: Game(game: Games.X, coverPokemon: "xerneas-game-icon", generation: 6, availableMethods: [.Encounters, .Masuda, .Pokeradar, .ChainFishing, .FriendSafari], isShinyCharmAvailable: true),
                         .Y: Game(game: Games.Y, coverPokemon: "yveltal-game-icon", generation: 6, availableMethods: [.Encounters, .Masuda, .Pokeradar, .ChainFishing, .FriendSafari], isShinyCharmAvailable: true),
                         .OmegaRuby: Game(game: Games.OmegaRuby, coverPokemon: "groudon-primal-game-icon", generation: 6, availableMethods: [.Encounters, .Masuda, .ChainFishing, .DexNav], isShinyCharmAvailable: true),
                         .AlphaSapphire: Game(game: Games.AlphaSapphire, coverPokemon: "kyogre-primal-game-icon", generation: 6, availableMethods: [.Encounters, .Masuda, .ChainFishing, .DexNav], isShinyCharmAvailable: true),
                         .Sun: Game(game: Games.Sun, coverPokemon: "solgaleo-game-icon", generation: 7, availableMethods: [.Encounters, .Masuda, .SosChaining], isShinyCharmAvailable: true),
                         .Moon: Game(game: Games.Moon, coverPokemon: "lunala-game-icon", generation: 7, availableMethods: [.Encounters, .Masuda, .SosChaining], isShinyCharmAvailable: true),
                         .UltraSun: Game(game: Games.UltraSun, coverPokemon: "necrozma-dusk-game-icon", generation: 7, availableMethods: [.Encounters, .Masuda, .SosChaining], isShinyCharmAvailable: true),
                         .UltraMoon: Game(game: Games.UltraMoon, coverPokemon: "necrozma-dawn-game-icon", generation: 7, availableMethods: [.Encounters, .Masuda, .SosChaining], isShinyCharmAvailable: true),
                         .LetsGoPikachu: Game(game: Games.LetsGoPikachu, coverPokemon: "pikachu-starter-game-icon", generation: 7, availableMethods: [.Encounters, .Lure], isShinyCharmAvailable: true),
                         .LetsGoEevee: Game(game: Games.LetsGoEevee, coverPokemon: "eevee-starter-game-icon", generation: 7, availableMethods: [.Encounters, .Lure], isShinyCharmAvailable: true),
                         .Sword: Game(game: Games.Sword, coverPokemon: "zacian-game-icon", generation: 8, availableMethods: [.Encounters, .Masuda], isShinyCharmAvailable: true),
                         .Shield: Game(game: Games.Shield, coverPokemon: "zamazenta-game-icon", generation: 8, availableMethods: [.Encounters, .Masuda], isShinyCharmAvailable: true),
                         .LegendsArceus: Game(game: Games.LegendsArceus, coverPokemon: "arceus-game-icon", generation: 8, availableMethods: [.Encounters], isShinyCharmAvailable: true),
                         .Scarlet: Game(game: Games.Scarlet, coverPokemon: "koraidon-game-icon", generation: 9, availableMethods: [.Encounters, .Masuda], isShinyCharmAvailable: true),
                         .Violet: Game(game: Games.Violet, coverPokemon: "miraidon-game-icon", generation: 9, availableMethods: [.Encounters, .Masuda], isShinyCharmAvailable: true),]
}
