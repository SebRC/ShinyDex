import UIKit

final class FollowerView: UIView {
    fileprivate static let stepDuration: CFTimeInterval = 0.4
    fileprivate static let stepAnimationKey = "followerSteps"

    let sheet: OverworldSheet
    let pixelScale: CGFloat
    fileprivate let spriteLayer = CALayer()

    init(sheet: OverworldSheet, pixelScale: CGFloat) {
        self.sheet = sheet
        self.pixelScale = pixelScale
        super.init(frame: .zero)
        isUserInteractionEnabled = false
        isAccessibilityElement = false
        spriteLayer.contents = sheet.image
        spriteLayer.magnificationFilter = .nearest
        spriteLayer.contentsGravity = .resize
        spriteLayer.contentsRect = sheet.makeContentsRect(ofFrame: sheet.forwardFrame)
        layer.addSublayer(spriteLayer)
        NotificationCenter.default.addObserver(self, selector: #selector(reduceMotionChanged), name: UIAccessibility.reduceMotionStatusDidChangeNotification, object: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: sheet.frameSizeInPixels.width * pixelScale, height: sheet.frameSizeInPixels.height * pixelScale)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        spriteLayer.frame = bounds
        CATransaction.commit()
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        updateStepping()
    }

    fileprivate func updateStepping() {
        spriteLayer.removeAnimation(forKey: FollowerView.stepAnimationKey)
        guard window != nil, !UIAccessibility.isReduceMotionEnabled, sheet.idleFrames.count > 1 else { return }
        let steps = CAKeyframeAnimation(keyPath: "contentsRect")
        steps.values = sheet.idleFrames.map { NSValue(cgRect: sheet.makeContentsRect(ofFrame: $0)) }
        steps.calculationMode = .discrete
        steps.duration = FollowerView.stepDuration * Double(sheet.idleFrames.count)
        steps.repeatCount = .infinity
        steps.isRemovedOnCompletion = false
        spriteLayer.add(steps, forKey: FollowerView.stepAnimationKey)
    }

    @objc fileprivate func reduceMotionChanged() {
        updateStepping()
    }
}
