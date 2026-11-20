import Foundation

enum PokedexRegions {
    static func getNumbers(inRegion region: Int) -> Range<Int>? {
        switch region {
        case 0: return 0..<151
        case 1: return 151..<251
        case 2: return 251..<386
        case 3: return 386..<493
        case 4: return 493..<649
        case 5: return 649..<721
        case 6: return 721..<807
        case 7: return 807..<898
        case 8: return 898..<905
        case 9: return 905..<1010
        default: return nil
        }
    }
}
