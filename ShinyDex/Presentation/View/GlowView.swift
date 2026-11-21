import UIKit

// The gradient is the view's own layer, so it always matches the view's bounds without manual frame updates.
class GlowView: UIView {
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }

    init(intensity: CGFloat = 0.3) {
        super.init(frame: .zero)
        isUserInteractionEnabled = false
        let gradient = layer as! CAGradientLayer
        gradient.type = .radial
        gradient.colors = [Color.accent.withAlphaComponent(intensity).cgColor, Color.accent.withAlphaComponent(0).cgColor]
        gradient.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 1)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
