import UIKit

extension CatchSummary {
    fileprivate static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    var ballName: String {
        return BallGrid.getFullName(of: caughtBall)
    }

    var speciesTitle: String {
        return PokemonSprites.makeTitle(pokemonName: pokemonName, formName: formName)
    }

    var spriteImage: UIImage? {
        return PokemonSprites.makeImage(pokemonName: pokemonName, formId: formId)
    }

    var spriteAssetName: String {
        return PokemonSprites.makeAssetName(pokemonName: pokemonName, formId: formId)
    }

    var formattedCaughtDate: String? {
        return caughtDate.map { CatchSummary.dateFormatter.string(from: $0) }
    }
}
