import Foundation

protocol LocationLinkProvider {
    func locationURL(forPokemonNamed name: String, number: Int, generation: Int) -> String
}
