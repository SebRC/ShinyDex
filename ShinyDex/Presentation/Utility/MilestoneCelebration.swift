import UIKit

enum MilestoneCelebration {
    fileprivate static let majorSparkleCount: Float = 46
    fileprivate static let minorSparkleCount: Float = 14
    fileprivate static let labelDuration: TimeInterval = 2.5

    static func play(_ milestone: ReachedMilestone, on target: UIView, in host: UIView, labelAnchor: UIView? = nil) {
        announce([milestone])
        animate(milestone, on: target, in: host, labelAnchor: labelAnchor)
    }

    static func announce(_ milestones: [ReachedMilestone]) {
        guard !milestones.isEmpty else { return }
        Haptics.playSuccess()
        UIAccessibility.post(notification: .announcement, argument: milestones.map(MilestoneText.makeMessage).joined(separator: " "))
    }

    static func animate(_ milestone: ReachedMilestone, on target: UIView, in host: UIView, labelAnchor: UIView? = nil) {
        let isMajor = milestone.isOddsMilestone
        glow(target, isMajor: isMajor)
        if !UIAccessibility.isReduceMotionEnabled {
            pop(target, isMajor: isMajor)
            burstSparkles(from: target, in: host, count: isMajor ? majorSparkleCount : minorSparkleCount)
        }
        if let labelAnchor = labelAnchor {
            showLabel(MilestoneText.makeShortLabel(for: milestone), onBottomEdgeOf: labelAnchor, in: host)
        }
    }

    fileprivate static func pop(_ target: UIView, isMajor: Bool) {
        let scale: CGFloat = isMajor ? 1.3 : 1.15
        UIView.animate(withDuration: 0.12, delay: 0, options: [.curveEaseOut, .allowUserInteraction]) {
            target.transform = CGAffineTransform(scaleX: scale, y: scale)
        } completion: { _ in
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.45, initialSpringVelocity: 0, options: [.allowUserInteraction]) {
                target.transform = .identity
            }
        }
    }

    fileprivate static func glow(_ target: UIView, isMajor: Bool) {
        target.layer.shadowColor = Color.accent.cgColor
        target.layer.shadowOffset = .zero
        target.layer.shadowRadius = isMajor ? 18 : 10
        let animation = CAKeyframeAnimation(keyPath: "shadowOpacity")
        animation.values = [0, isMajor ? 1 : 0.7, 0]
        animation.keyTimes = [0, 0.2, 1]
        animation.duration = isMajor ? 1.6 : 0.9
        target.layer.add(animation, forKey: "milestoneGlow")
    }

    fileprivate static func burstSparkles(from target: UIView, in host: UIView, count: Float) {
        let center = target.convert(CGPoint(x: target.bounds.midX, y: target.bounds.midY), to: host)
        let emitter = CAEmitterLayer()
        emitter.emitterPosition = center
        emitter.emitterShape = .circle
        emitter.emitterSize = CGSize(width: min(target.bounds.width, 120), height: target.bounds.height / 2)
        emitter.emitterCells = [makeSparkleCell(color: Color.accent, count: count), makeSparkleCell(color: Color.Orange200, count: count / 2)].compactMap { $0 }
        emitter.beginTime = CACurrentMediaTime()
        host.layer.addSublayer(emitter)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            emitter.birthRate = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            emitter.removeFromSuperlayer()
        }
    }

    fileprivate static func makeSparkleCell(color: UIColor, count: Float) -> CAEmitterCell? {
        guard let sparkle = makeSparkleImage(color: color) else { return nil }
        let cell = CAEmitterCell()
        cell.contents = sparkle.cgImage
        cell.birthRate = count / 0.12
        cell.lifetime = 1.1
        cell.lifetimeRange = 0.3
        cell.velocity = 180
        cell.velocityRange = 80
        cell.emissionRange = .pi * 2
        cell.yAcceleration = 160
        cell.scale = 0.6
        cell.scaleRange = 0.3
        cell.scaleSpeed = -0.4
        cell.spin = 2
        cell.spinRange = 4
        cell.alphaSpeed = -0.8
        return cell
    }

    fileprivate static func makeSparkleImage(color: UIColor) -> UIImage? {
        guard let symbol = UIImage.makeSymbol("sparkle", pointSize: 14, weight: .bold) else { return nil }
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 3
        return UIGraphicsImageRenderer(size: symbol.size, format: format).image { _ in
            symbol.withTintColor(color, renderingMode: .alwaysOriginal).draw(at: .zero)
        }
    }

    fileprivate static func showLabel(_ text: String, onBottomEdgeOf anchor: UIView, in host: UIView) {
        let label = PaddedPillLabel(text: text)
        host.addAutoLayoutSubviews(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: anchor.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: anchor.bottomAnchor)
        ])
        label.alpha = 0
        label.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        UIView.animate(withDuration: 0.3, delay: 0.1, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: []) {
            label.alpha = 1
            label.transform = .identity
        }
        UIView.animate(withDuration: 0.4, delay: labelDuration, options: []) {
            label.alpha = 0
        } completion: { _ in
            label.removeFromSuperview()
        }
    }
}

fileprivate final class PaddedPillLabel: UIView {
    init(text: String) {
        super.init(frame: .zero)
        backgroundColor = Color.accent
        layer.cornerRadius = CornerRadius.capsule(height: 26)
        isUserInteractionEnabled = false
        isAccessibilityElement = false
        let label = UILabel(style: .subheadline, weight: .bold, color: Color.background)
        label.text = text
        addAutoLayoutSubviews(label)
        label.pinEdges(to: self, insets: UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 12))
        heightAnchor.constraint(equalToConstant: 26).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
