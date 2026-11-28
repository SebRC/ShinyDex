import UIKit

final class OddsCurveView: UIView {
    static let plotHeight: CGFloat = 200
    fileprivate static let plotInsets = UIEdgeInsets(top: 30, left: 40, bottom: 26, right: Spacing.large)
    fileprivate static let markerSide: CGFloat = 10
    fileprivate static let ringWidth: CGFloat = 2
    fileprivate static let milestoneMarkerSide: CGFloat = 8

    fileprivate var summary: OddsCurveSummary?
    fileprivate let areaLayer = CAShapeLayer()
    fileprivate let lineLayer = CAShapeLayer()
    fileprivate let gridLayer = CAShapeLayer()
    fileprivate let currentGuideLayer = CAShapeLayer()
    fileprivate let scrubLayer = CAShapeLayer()
    fileprivate let milestoneLayer = CAShapeLayer()
    fileprivate let currentMarker = UIView()
    fileprivate let scrubMarker = UIView()
    fileprivate let scrubLabel = UILabel(style: .caption1, weight: .semibold, color: Color.textPrimary)
    fileprivate let scrubBubble = UIView()
    fileprivate var axisLabels = [UILabel]()

    override init(frame: CGRect) {
        super.init(frame: frame)
        gridLayer.strokeColor = Color.separator.cgColor
        gridLayer.lineWidth = 1
        gridLayer.lineDashPattern = [3, 3]
        areaLayer.fillColor = Color.accent.withAlphaComponent(0.14).cgColor
        lineLayer.strokeColor = Color.accent.cgColor
        lineLayer.fillColor = UIColor.clear.cgColor
        lineLayer.lineWidth = 2
        lineLayer.lineJoin = .round
        currentGuideLayer.strokeColor = Color.textTertiary.cgColor
        currentGuideLayer.lineWidth = 1
        currentGuideLayer.lineDashPattern = [2, 3]
        scrubLayer.strokeColor = Color.textSecondary.cgColor
        scrubLayer.lineWidth = 1
        milestoneLayer.fillColor = Color.surface.cgColor
        milestoneLayer.strokeColor = Color.textPrimary.cgColor
        milestoneLayer.lineWidth = 2
        [gridLayer, areaLayer, currentGuideLayer, lineLayer, milestoneLayer, scrubLayer].forEach(layer.addSublayer)
        for marker in [currentMarker, scrubMarker] {
            marker.backgroundColor = Color.accent
            marker.layer.cornerRadius = OddsCurveView.markerSide / 2
            marker.layer.borderColor = Color.surface.cgColor
            marker.layer.borderWidth = OddsCurveView.ringWidth
            marker.bounds = CGRect(x: 0, y: 0, width: OddsCurveView.markerSide + 2 * OddsCurveView.ringWidth, height: OddsCurveView.markerSide + 2 * OddsCurveView.ringWidth)
            marker.layer.cornerRadius = marker.bounds.width / 2
            addSubview(marker)
        }
        scrubBubble.backgroundColor = Color.surfaceRaised
        scrubBubble.layer.cornerRadius = CornerRadius.small
        scrubBubble.addAutoLayoutSubviews(scrubLabel)
        scrubLabel.font = UIFont.make(.caption1, weight: .semibold, monospacedDigits: true)
        scrubLabel.pinEdges(to: scrubBubble, insets: UIEdgeInsets(top: Spacing.extraSmall, left: Spacing.small, bottom: Spacing.extraSmall, right: Spacing.small))
        addSubview(scrubBubble)
        setScrubHidden(true)
        heightAnchor.constraint(equalToConstant: OddsCurveView.plotHeight).isActive = true
        let scrub = UILongPressGestureRecognizer(target: self, action: #selector(scrubbed))
        scrub.minimumPressDuration = 0
        addGestureRecognizer(scrub)
        isAccessibilityElement = true
        accessibilityTraits = .image
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(summary: OddsCurveSummary) {
        self.summary = summary
        axisLabels.forEach { $0.removeFromSuperview() }
        axisLabels = OddsCurveView.gridChances.map { OddsCurveView.makeAxisLabel("\(Int($0))%") } + [OddsCurveView.makeAxisLabel("0"), OddsCurveView.makeAxisLabel(summary.points.last?.encounters.grouped ?? "")]
        axisLabels.forEach(addSubview)
        accessibilityLabel = "Chance of finding the shiny by encounter count"
        let milestones = summary.milestones.map { "\(Int($0.chance))% by \($0.encounters.grouped)" }
        accessibilityValue = (["\(CatchLuckText.formatPercent(summary.current.chance)) at \(summary.current.encounters.grouped) encounters"] + milestones).joined(separator: ", ")
        setNeedsLayout()
    }

    // MARK: Layout

    fileprivate static let gridChances = [25.0, 50.0, 75.0, 100.0]

    fileprivate var plotRect: CGRect {
        return bounds.inset(by: OddsCurveView.plotInsets)
    }

    fileprivate func locate(_ point: OddsCurvePoint) -> CGPoint {
        let rect = plotRect
        let lastEncounters = max(summary?.points.last?.encounters ?? 1, 1)
        return CGPoint(x: rect.minX + rect.width * CGFloat(point.encounters) / CGFloat(lastEncounters),
                       y: rect.maxY - rect.height * CGFloat(point.chance / 100))
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let summary = summary, plotRect.width > 0 else { return }
        let rect = plotRect
        let grid = UIBezierPath()
        for (index, chance) in OddsCurveView.gridChances.enumerated() {
            let y = locate(OddsCurvePoint(encounters: 0, chance: chance)).y
            grid.move(to: CGPoint(x: rect.minX, y: y))
            grid.addLine(to: CGPoint(x: rect.maxX, y: y))
            let label = axisLabels[index]
            label.sizeToFit()
            label.center = CGPoint(x: rect.minX - Spacing.small - label.bounds.width / 2, y: y)
        }
        grid.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        grid.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        gridLayer.path = grid.cgPath
        let startLabel = axisLabels[OddsCurveView.gridChances.count]
        let endLabel = axisLabels[OddsCurveView.gridChances.count + 1]
        [startLabel, endLabel].forEach { $0.sizeToFit() }
        startLabel.frame.origin = CGPoint(x: rect.minX, y: rect.maxY + Spacing.extraSmall)
        endLabel.frame.origin = CGPoint(x: rect.maxX - endLabel.bounds.width, y: rect.maxY + Spacing.extraSmall)

        let line = UIBezierPath()
        for (index, point) in summary.points.enumerated() {
            index == 0 ? line.move(to: locate(point)) : line.addLine(to: locate(point))
        }
        lineLayer.path = line.cgPath
        let area = line.copy() as! UIBezierPath
        area.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        area.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        area.close()
        areaLayer.path = area.cgPath

        let milestones = UIBezierPath()
        for milestone in summary.milestones where milestone.encounters <= summary.points.last?.encounters ?? 0 {
            let center = locate(OddsCurvePoint(encounters: milestone.encounters, chance: milestone.chance))
            let side = OddsCurveView.milestoneMarkerSide
            milestones.append(UIBezierPath(ovalIn: CGRect(x: center.x - side / 2, y: center.y - side / 2, width: side, height: side)))
        }
        milestoneLayer.path = milestones.cgPath

        let current = locate(summary.current)
        let guide = UIBezierPath()
        guide.move(to: CGPoint(x: current.x, y: rect.maxY))
        guide.addLine(to: current)
        currentGuideLayer.path = guide.cgPath
        currentMarker.center = current
    }

    fileprivate static func makeAxisLabel(_ text: String) -> UILabel {
        let label = UILabel(style: .caption2, weight: .semibold, color: Color.textQuaternary)
        label.font = UIFont.make(.caption2, weight: .semibold, monospacedDigits: true)
        label.text = text
        return label
    }

    // MARK: Scrubbing

    @objc fileprivate func scrubbed(_ gesture: UILongPressGestureRecognizer) {
        guard let summary = summary, summary.points.count > 1 else { return }
        switch gesture.state {
        case .began, .changed:
            let rect = plotRect
            let fraction = min(max((gesture.location(in: self).x - rect.minX) / rect.width, 0), 1)
            let index = Int((fraction * CGFloat(summary.points.count - 1)).rounded())
            showScrub(at: summary.points[index])
        default:
            setScrubHidden(true)
        }
    }

    fileprivate func showScrub(at point: OddsCurvePoint) {
        let rect = plotRect
        let location = locate(point)
        let path = UIBezierPath()
        path.move(to: CGPoint(x: location.x, y: rect.minY))
        path.addLine(to: CGPoint(x: location.x, y: rect.maxY))
        scrubLayer.path = path.cgPath
        scrubMarker.center = location
        scrubLabel.text = "\(point.encounters.grouped) · \(CatchLuckText.formatPercent(point.chance))"
        let size = scrubBubble.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        let x = min(max(location.x - size.width / 2, bounds.minX), bounds.maxX - size.width)
        scrubBubble.frame = CGRect(x: x, y: 0, width: size.width, height: size.height)
        setScrubHidden(false)
    }

    fileprivate func setScrubHidden(_ isHidden: Bool) {
        scrubLayer.isHidden = isHidden
        scrubMarker.isHidden = isHidden
        scrubBubble.isHidden = isHidden
    }
}
