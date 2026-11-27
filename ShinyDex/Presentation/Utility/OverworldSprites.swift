import UIKit

struct OverworldSheet {
    let image: CGImage
    let stepFrames: [Int]
    let forwardFrame: Int
    var ballRaisingFrames = [Int]()

    var frameCount: Int {
        return image.width / image.height
    }

    var frameSizeInPixels: CGSize {
        return CGSize(width: image.height, height: image.height)
    }

    func makeContentsRect(ofFrame frame: Int) -> CGRect {
        let width = 1 / CGFloat(frameCount)
        return CGRect(x: CGFloat(frame) * width, y: 0, width: width, height: 1)
    }
}

enum OverworldSprites {
    static func makeCompanionSheet(number: Int, formId: String?, gender: Gender?) -> OverworldSheet? {
        let dexNumber = number + 1
        let candidates = [
            formId.map { "follower-\(dexNumber)-\($0)" },
            gender == .female ? "follower-\(dexNumber)-female" : nil,
            "follower-\(dexNumber)"
        ].compactMap { $0 }
        guard let image = candidates.lazy.compactMap({ UIImage(named: $0)?.cgImage }).first else { return nil }
        return OverworldSheet(image: image, stepFrames: [0, 1], forwardFrame: 2)
    }

    static func makePlayerSheet(game: Games, isFemale: Bool) -> OverworldSheet? {
        guard let style = findPlayerStyle(of: game), let image = UIImage(named: "player-\(style)-\(isFemale ? "female" : "male")")?.cgImage else { return nil }
        let sheet = OverworldSheet(image: image, stepFrames: [0, 1, 2, 3], forwardFrame: 4)
        let ballRaisingFrames = [5, 6]
        guard sheet.frameCount > ballRaisingFrames.last! else { return sheet }
        return OverworldSheet(image: image, stepFrames: sheet.stepFrames, forwardFrame: sheet.forwardFrame, ballRaisingFrames: ballRaisingFrames)
    }

    fileprivate static func findPlayerStyle(of game: Games) -> String? {
        switch game {
        case .Ruby, .Sapphire: return "rubysapphire"
        case .Emerald: return "emerald"
        case .FireRed, .LeafGreen: return "fireredleafgreen"
        case .Diamond, .Pearl: return "diamondpearl"
        case .Platinum: return "platinum"
        case .Heartgold, .SoulSilver: return "heartgoldsoulsilver"
        default: return nil
        }
    }
}

final class OverworldSpriteView: UIView {
    let sheet: OverworldSheet

    init(sheet: OverworldSheet) {
        self.sheet = sheet
        super.init(frame: .zero)
        layer.contents = sheet.image
        layer.magnificationFilter = .nearest
        layer.contentsGravity = .resize
        showFrame(sheet.forwardFrame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func showFrame(_ frame: Int) {
        layer.contentsRect = sheet.makeContentsRect(ofFrame: frame)
    }
}
