import UIKit

final class JourneyPlaybackView: UIView {
    struct Companion {
        let sheet: OverworldSheet
        let caption: String
    }

    fileprivate enum Timing {
        static let intro: CFTimeInterval = 0.8
        static let longestJoinInterval: CFTimeInterval = 0.9
        static let shortestJoinInterval: CFTimeInterval = 0.35
        static let joiningBudget: CFTimeInterval = 12
        static let joinTravel: CFTimeInterval = 0.7
        static let runAfterLastJoin: CFTimeInterval = 1.2
        static let stopping: CFTimeInterval = 0.5
        static let turnStagger: CFTimeInterval = 0.06
        static let hop: CFTimeInterval = 0.35
        static let ballRaiseStep: CFTimeInterval = 0.18
        static let endCardDelay: CFTimeInterval = 0.3
        static let fade: CFTimeInterval = 0.4
        static let playerStepsPerSecond: Double = 10
        static let companionStepsPerSecond: Double = 6
        static let companionStepStagger: CFTimeInterval = 0.13
        static let companionIdleStepsPerSecond: Double = 2.5
        static let sparkle: CFTimeInterval = 0.6
    }

    fileprivate enum Metrics {
        static let pixelScales: [CGFloat] = [3, 2.5, 2, 1.5, 1]
        static let smallestPreferredPixelScale: CGFloat = 2
        static let maximumLanes = 3
        static let companionSpacing: CGFloat = 20
        static let largeCompanionSpacing: CGFloat = 36
        static let companionHalfWidth: CGFloat = 12
        static let largeCompanionHalfWidth: CGFloat = 24
        static let playerHalfWidth: CGFloat = 12
        static let laneGap: CGFloat = 12
        static let runSpeed: CGFloat = 64
        static let hopHeight: CGFloat = 6
        static let pathAboveBackLane: CGFloat = 10
        static let pathBelowFrontLane: CGFloat = 6
    }

    fileprivate struct Formation {
        var pixelScale: CGFloat = 1
        var laneCount = 1
        var playerFeet = CGPoint.zero
        var companionFeet = [CGPoint]()
    }

    var onFinished: (() -> Void)?

    fileprivate let player: OverworldSpriteView
    fileprivate let companions: [Companion]
    fileprivate let companionViews: [OverworldSpriteView]
    fileprivate let sparkleViews: [PlaybackSparkleView]
    fileprivate let ground = PlaybackGroundView()
    fileprivate let titleLabel = UILabel(style: .title2, weight: .bold, color: Color.textPrimary)
    fileprivate let subtitleLabel = UILabel(style: .subheadline, weight: .semibold, color: Color.accent)
    fileprivate let captionLabel = UILabel(style: .footnote, weight: .semibold, color: Color.textSecondary)
    fileprivate let footerLabel = UILabel(style: .caption2, weight: .semibold, color: Color.textQuaternary)
    fileprivate var formation = Formation()
    fileprivate var displayLink: CADisplayLink?
    fileprivate var startTime: CFTimeInterval?
    fileprivate var elapsed: CFTimeInterval = 0
    fileprivate var hasFinished = false

    fileprivate var joinInterval: CFTimeInterval {
        return min(max(Timing.joiningBudget / Double(max(companions.count, 1)), Timing.shortestJoinInterval), Timing.longestJoinInterval)
    }

    fileprivate var stopStart: CFTimeInterval {
        return findJoinStart(of: companions.count - 1) + Timing.joinTravel + Timing.runAfterLastJoin
    }

    fileprivate var stopEnd: CFTimeInterval {
        return stopStart + Timing.stopping
    }

    fileprivate var endCardStart: CFTimeInterval {
        return findTurnTime(ofSpriteAt: companions.count) + Timing.hop + Timing.endCardDelay
    }

    fileprivate var duration: CFTimeInterval {
        return endCardStart + Timing.fade
    }

    init(title: String, subtitle: String, player: OverworldSheet, companions: [Companion]) {
        self.player = OverworldSpriteView(sheet: player)
        self.companions = companions
        companionViews = companions.map { OverworldSpriteView(sheet: $0.sheet) }
        sparkleViews = companions.map { _ in PlaybackSparkleView() }
        super.init(frame: .zero)
        backgroundColor = Color.background
        clipsToBounds = true
        titleLabel.text = title
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        subtitleLabel.text = subtitle
        subtitleLabel.textAlignment = .center
        captionLabel.textAlignment = .center
        footerLabel.text = "ShinyDex"
        addSubview(ground)
        companionViews.forEach(addSubview)
        addSubview(self.player)
        sparkleViews.forEach(addSubview)
        addAutoLayoutSubviews(titleLabel, subtitleLabel, footerLabel)
        addSubview(captionLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: Spacing.extraLarge),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Spacing.screenMargin),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Spacing.screenMargin),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Spacing.extraSmall),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            footerLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            footerLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Spacing.medium)
        ])
        isAccessibilityElement = true
        accessibilityLabel = "Journey playback"
        accessibilityValue = ([title, subtitle] + companions.map { $0.caption }).joined(separator: ", ")
        update()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        formation = JourneyPlaybackView.makeFormation(in: bounds, companions: companions)
        let scale = formation.pixelScale
        let backLaneY = formation.playerFeet.y - CGFloat(formation.laneCount - 1) * Metrics.laneGap * scale
        ground.frame = bounds
        ground.pixelScale = scale
        ground.pathTop = backLaneY - Metrics.pathAboveBackLane * scale
        ground.pathBottom = formation.playerFeet.y + Metrics.pathBelowFrontLane * scale
        let captionHeight = captionLabel.font.lineHeight.rounded(.up)
        captionLabel.frame = CGRect(x: Spacing.screenMargin, y: ground.pathBottom + Spacing.large, width: bounds.width - Spacing.screenMargin * 2, height: captionHeight)
        update()
    }

    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        if newWindow == nil {
            stopDisplayLink()
        }
    }

    func play() {
        guard displayLink == nil, !hasFinished else { return }
        startTime = nil
        let link = CADisplayLink(target: self, selector: #selector(tick))
        link.add(to: .main, forMode: .common)
        displayLink = link
    }

    func skipToEnd() {
        elapsed = max(elapsed, duration)
        startTime = nil
        update()
    }

    func renderImage() -> UIImage {
        companionViews.forEach { $0.showFrame($0.sheet.forwardFrame) }
        sparkleViews.forEach { $0.isHidden = true }
        let image = UIGraphicsImageRenderer(bounds: bounds).image { _ in
            drawHierarchy(in: bounds, afterScreenUpdates: true)
        }
        update()
        return image
    }

    @objc fileprivate func tick(_ link: CADisplayLink) {
        let start = startTime ?? link.timestamp - elapsed
        startTime = start
        elapsed = link.timestamp - start
        update()
    }

    fileprivate func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }

    // MARK: Timeline

    fileprivate func findJoinStart(of index: Int) -> CFTimeInterval {
        return Timing.intro + Double(max(index, 0)) * joinInterval
    }

    fileprivate func findTurnTime(ofSpriteAt index: Int) -> CFTimeInterval {
        return stopEnd + Double(index) * Timing.turnStagger
    }

    fileprivate func findScrollDistance(at time: CFTimeInterval) -> CGFloat {
        let speed = Metrics.runSpeed * formation.pixelScale
        guard time > stopStart else { return speed * CGFloat(time) }
        let braking = CGFloat(min(time - stopStart, Timing.stopping))
        return speed * CGFloat(stopStart) + speed * (braking - braking * braking / (2 * CGFloat(Timing.stopping)))
    }

    fileprivate func findHopOffset(ofSpriteAt index: Int, at time: CFTimeInterval) -> CGFloat {
        let progress = (time - findTurnTime(ofSpriteAt: index)) / Timing.hop
        guard progress > 0, progress < 1 else { return 0 }
        return -CGFloat(sin(Double.pi * progress)) * Metrics.hopHeight * formation.pixelScale
    }

    fileprivate func update() {
        let time = min(elapsed, duration)
        let isRunning = time < stopEnd
        ground.scrollDistance = findScrollDistance(at: time)
        ground.setNeedsDisplay()

        let playerStep = player.sheet.stepFrames[Int(time * Timing.playerStepsPerSecond) % player.sheet.stepFrames.count]
        player.showFrame(isRunning ? playerStep : findPlayerPoseFrame(at: time))
        place(player, feet: formation.playerFeet, hop: player.sheet.ballRaisingFrames.isEmpty ? findHopOffset(ofSpriteAt: 0, at: time) : 0)

        for (index, view) in companionViews.enumerated() where formation.companionFeet.indices.contains(index) {
            let joinStart = findJoinStart(of: index)
            view.isHidden = time < joinStart
            let progress = min(max((time - joinStart) / Timing.joinTravel, 0), 1)
            let eased = CGFloat(1 - pow(1 - progress, 3))
            let slot = formation.companionFeet[index]
            let entryX = -view.sheet.frameSizeInPixels.width * formation.pixelScale
            let stagger = Double(index) * Timing.companionStepStagger
            let step = view.sheet.stepFrames[Int((time + stagger) * Timing.companionStepsPerSecond) % view.sheet.stepFrames.count]
            view.showFrame(isRunning ? step : findStandingFrame(of: view, turnedAt: findTurnTime(ofSpriteAt: index + 1), stagger: stagger))
            place(view, feet: CGPoint(x: entryX + (slot.x - entryX) * eased, y: slot.y), hop: findHopOffset(ofSpriteAt: index + 1, at: time))
            let sparkleProgress = findSparkleProgress(at: time, triggers: [joinStart + Timing.joinTravel, findTurnTime(ofSpriteAt: index + 1)])
            placeSparkle(sparkleViews[index], over: view, progress: sparkleProgress)
        }

        let joiningIndex = (0..<companions.count).last { findJoinStart(of: $0) <= time }
        captionLabel.text = joiningIndex.map { companions[$0].caption }
        captionLabel.alpha = time < stopStart ? 1 : max(0, 1 - CGFloat((time - stopStart) / Timing.fade))
        titleLabel.alpha = min(CGFloat(time / Timing.intro), 1)
        subtitleLabel.alpha = min(max(CGFloat((time - endCardStart) / Timing.fade), 0), 1)

        if elapsed >= duration && !hasFinished {
            hasFinished = true
            if (companionViews.allSatisfy { $0.sheet.idleFrames.isEmpty }) {
                stopDisplayLink()
            }
            onFinished?()
        }
    }

    fileprivate func findStandingFrame(of view: OverworldSpriteView, turnedAt turnTime: CFTimeInterval, stagger: CFTimeInterval) -> Int {
        let idleTime = elapsed - turnTime - Timing.hop
        guard displayLink != nil, idleTime > 0, !view.sheet.idleFrames.isEmpty else { return view.sheet.forwardFrame }
        return view.sheet.idleFrames[Int((idleTime + stagger) * Timing.companionIdleStepsPerSecond) % view.sheet.idleFrames.count]
    }

    fileprivate func findSparkleProgress(at time: CFTimeInterval, triggers: [CFTimeInterval]) -> CGFloat? {
        return triggers.lazy.map { CGFloat((time - $0) / Timing.sparkle) }.first { $0 >= 0 && $0 < 1 }
    }

    fileprivate func placeSparkle(_ sparkle: PlaybackSparkleView, over sprite: OverworldSpriteView, progress: CGFloat?) {
        sparkle.isHidden = progress == nil || sprite.isHidden
        guard let progress = progress, !sparkle.isHidden else { return }
        let size = PlaybackSparkleView.sizeInPixels * formation.pixelScale
        sparkle.frame = CGRect(x: sprite.frame.midX - size / 2, y: sprite.frame.midY - size / 2, width: size, height: size)
        sparkle.layer.zPosition = sprite.layer.zPosition + 1
        sparkle.pixelScale = formation.pixelScale
        sparkle.progress = progress
    }

    fileprivate func findPlayerPoseFrame(at time: CFTimeInterval) -> Int {
        let raisingSteps = Int(((time - findTurnTime(ofSpriteAt: 0)) / Timing.ballRaiseStep).rounded(.down))
        guard raisingSteps > 0, !player.sheet.ballRaisingFrames.isEmpty else { return player.sheet.forwardFrame }
        return player.sheet.ballRaisingFrames[min(raisingSteps, player.sheet.ballRaisingFrames.count) - 1]
    }

    fileprivate func place(_ view: OverworldSpriteView, feet: CGPoint, hop: CGFloat) {
        let size = CGSize(width: view.sheet.frameSizeInPixels.width * formation.pixelScale, height: view.sheet.frameSizeInPixels.height * formation.pixelScale)
        view.frame = CGRect(x: feet.x - size.width / 2, y: feet.y - size.height + hop, width: size.width, height: size.height)
        view.layer.zPosition = feet.y
    }

    // MARK: Formation

    fileprivate static func makeFormation(in bounds: CGRect, companions: [Companion]) -> Formation {
        let screenScale = UIScreen.main.scale
        let preferredScales = Metrics.pixelScales.filter { $0 >= Metrics.smallestPreferredPixelScale }
        let smallScales = Metrics.pixelScales.filter { $0 < Metrics.smallestPreferredPixelScale }
        let candidates = [preferredScales, smallScales].flatMap { scales in
            (1...Metrics.maximumLanes).flatMap { laneCount in scales.map { ($0, laneCount) } }
        }
        var fallback = Formation()
        for (scale, laneCount) in candidates {
            let formation = makeFormation(in: bounds, companions: companions, pixelScale: (scale * screenScale).rounded() / screenScale, laneCount: laneCount)
            fallback = formation
            let leftmost = zip(formation.companionFeet, companions).map { feet, companion in feet.x - findHalfWidth(of: companion.sheet) * formation.pixelScale }.min() ?? 0
            if leftmost >= Spacing.screenMargin {
                return formation
            }
        }
        return fallback
    }

    fileprivate static func makeFormation(in bounds: CGRect, companions: [Companion], pixelScale: CGFloat, laneCount: Int) -> Formation {
        let laneGap = Metrics.laneGap * pixelScale
        let frontLaneY = (bounds.midY + CGFloat(laneCount - 1) * laneGap / 2).rounded()
        let playerFeet = CGPoint(x: (bounds.width - Spacing.screenMargin - Metrics.playerHalfWidth * pixelScale).rounded(), y: frontLaneY)
        var laneCursors = (0..<laneCount).map { lane in playerFeet.x - (lane % 2 == 1 ? Metrics.companionSpacing * pixelScale / 2 : 0) }
        let companionFeet = companions.enumerated().map { index, companion -> CGPoint in
            let lane = index % laneCount
            laneCursors[lane] -= findSpacing(of: companion.sheet) * pixelScale
            return CGPoint(x: laneCursors[lane].rounded(), y: frontLaneY - CGFloat(lane) * laneGap)
        }
        return Formation(pixelScale: pixelScale, laneCount: laneCount, playerFeet: playerFeet, companionFeet: companionFeet)
    }

    fileprivate static func isLarge(_ sheet: OverworldSheet) -> Bool {
        return sheet.frameSizeInPixels.width > 32
    }

    fileprivate static func findSpacing(of sheet: OverworldSheet) -> CGFloat {
        return isLarge(sheet) ? Metrics.largeCompanionSpacing : Metrics.companionSpacing
    }

    fileprivate static func findHalfWidth(of sheet: OverworldSheet) -> CGFloat {
        return isLarge(sheet) ? Metrics.largeCompanionHalfWidth : Metrics.companionHalfWidth
    }
}

final class PlaybackSparkleView: UIView {
    static let sizeInPixels: CGFloat = 44
    fileprivate static let starAngles: [CGFloat] = [20, 95, 160, 215, 290, 340]
    fileprivate static let innerRadius: CGFloat = 6
    fileprivate static let outerRadius: CGFloat = 19
    fileprivate static let longestArm: CGFloat = 3
    fileprivate static let fadeStart: CGFloat = 0.7

    var pixelScale: CGFloat = 1
    var progress: CGFloat = 0 {
        didSet {
            setNeedsDisplay()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        isOpaque = false
        backgroundColor = .clear
        isUserInteractionEnabled = false
        isHidden = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        let pixel = max(pixelScale.rounded(), 1)
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = (PlaybackSparkleView.innerRadius + (PlaybackSparkleView.outerRadius - PlaybackSparkleView.innerRadius) * progress) * pixelScale
        let arm = (sin(.pi * progress) * PlaybackSparkleView.longestArm).rounded()
        let alpha = progress < PlaybackSparkleView.fadeStart ? 1 : (1 - progress) / (1 - PlaybackSparkleView.fadeStart)
        for (index, degrees) in PlaybackSparkleView.starAngles.enumerated() {
            let angle = degrees * .pi / 180
            let color = index.isMultiple(of: 2) ? Color.textPrimary : Color.accent
            color.withAlphaComponent(alpha).setFill()
            let snapped = CGPoint(x: ((center.x + cos(angle) * radius) / pixel).rounded() * pixel, y: ((center.y + sin(angle) * radius) / pixel).rounded() * pixel)
            context.fill(CGRect(x: snapped.x, y: snapped.y, width: pixel, height: pixel))
            guard arm > 0 else { continue }
            context.fill(CGRect(x: snapped.x - arm * pixel, y: snapped.y, width: arm * pixel * 2 + pixel, height: pixel))
            context.fill(CGRect(x: snapped.x, y: snapped.y - arm * pixel, width: pixel, height: arm * pixel * 2 + pixel))
        }
    }
}

final class PlaybackGroundView: UIView {
    fileprivate static let tileSize: CGFloat = 16
    fileprivate static let tuftSize: CGFloat = 3

    var pixelScale: CGFloat = 1
    var pathTop: CGFloat = 0
    var pathBottom: CGFloat = 0
    var scrollDistance: CGFloat = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        isOpaque = false
        backgroundColor = .clear
        isUserInteractionEnabled = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext(), pathBottom > pathTop else { return }
        let tile = PlaybackGroundView.tileSize * pixelScale
        let line = max(pixelScale.rounded(), 1)
        Color.surface.setFill()
        context.fill(CGRect(x: 0, y: pathTop, width: bounds.width, height: pathBottom - pathTop))
        Color.separator.setFill()
        context.fill(CGRect(x: 0, y: pathTop, width: bounds.width, height: line))
        context.fill(CGRect(x: 0, y: pathBottom - line, width: bounds.width, height: line))

        let firstTile = Int((scrollDistance / tile).rounded(.down))
        let lastTile = firstTile + Int((bounds.width / tile).rounded(.up)) + 1
        for worldTile in firstTile...lastTile {
            let x = (CGFloat(worldTile) * tile - scrollDistance).rounded()
            Color.surfaceRaised.setFill()
            context.fill(CGRect(x: x, y: pathTop + line, width: line, height: pathBottom - pathTop - line * 2))
            let pattern = (worldTile &* 2654435761) & 0xFFFF
            if pattern % 3 == 0 {
                drawTuft(in: context, at: CGPoint(x: x + tile / 2, y: pathTop - tile / 2))
            }
            if pattern % 5 == 1 {
                drawTuft(in: context, at: CGPoint(x: x + tile / 3, y: pathBottom + tile / 2))
            }
        }
    }

    fileprivate func drawTuft(in context: CGContext, at point: CGPoint) {
        let pixel = pixelScale
        let size = PlaybackGroundView.tuftSize * pixel
        Color.separator.setFill()
        context.fill(CGRect(x: point.x - size, y: point.y - size, width: pixel, height: size))
        context.fill(CGRect(x: point.x, y: point.y - size * 1.5, width: pixel, height: size * 1.5))
        context.fill(CGRect(x: point.x + size, y: point.y - size, width: pixel, height: size))
    }
}
