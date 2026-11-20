import Foundation

protocol LocationLinkProvider {
    func makeLocationURL(forPokemonNamed name: String, number: Int, generation: Int) -> String
}
