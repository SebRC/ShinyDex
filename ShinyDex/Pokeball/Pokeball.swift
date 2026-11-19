import Foundation

class Pokeball {
    let ballName: String
    let name: String

    init(ballName: String) {
        self.ballName = ballName
        name = ballName.capitalizingFirstLetter()
    }
}
