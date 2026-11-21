import UIKit

final class GoalProgressCard: UIControl {
    fileprivate let onTap: () -> Void

    init(year: Int, goal: CatchStatistics.Goal, onTap: @escaping () -> Void) {
        self.onTap = onTap
        super.init(frame: .zero)
        backgroundColor = Color.surface
        layer.cornerRadius = CornerRadius.standard
        addTarget(self, action: #selector(tapped), for: .touchUpInside)

        let captionLabel = UILabel(style: .caption1, weight: .semibold, color: Color.textTertiary)
        captionLabel.text = "SHINIES FOUND IN \(year)"
        let valueLabel = UILabel(style: .title1, weight: .bold, color: goal.isReached ? Color.accent : Color.textPrimary)
        valueLabel.font = UIFont.make(.title1, weight: .bold, monospacedDigits: true)
        valueLabel.text = "\(goal.foundCount.grouped) / \(goal.target.grouped)"
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.progressTintColor = Color.accent
        progressView.trackTintColor = Color.surfaceRaised
        progressView.progress = Float(min(Double(goal.foundCount) / Double(goal.target), 1))
        let paceLabel = UILabel(style: .caption1, color: Color.textTertiary)
        paceLabel.text = GoalProgressCard.describePace(of: goal)

        let stack = UIStackView(arrangedSubviews: [captionLabel, valueLabel, progressView, paceLabel])
        stack.axis = .vertical
        stack.spacing = 2
        stack.setCustomSpacing(10, after: valueLabel)
        stack.setCustomSpacing(8, after: progressView)
        stack.isUserInteractionEnabled = false
        addAutoLayoutSubviews(stack)
        stack.pinEdges(to: self, insets: UIEdgeInsets(top: 12, left: 14, bottom: 12, right: 14))

        let chevron = UIImageView(image: UIImage.makeSymbol("chevron.right", pointSize: 12, weight: .semibold))
        chevron.tintColor = Color.textQuaternary
        addAutoLayoutSubviews(chevron)
        NSLayoutConstraint.activate([
            chevron.topAnchor.constraint(equalTo: topAnchor, constant: 13),
            chevron.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12)
        ])

        isAccessibilityElement = true
        accessibilityTraits = .button
        accessibilityLabel = "\(year) goal"
        accessibilityValue = "\(goal.foundCount) of \(goal.target) shinies, \(paceLabel.text ?? "")"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? Color.surfaceRaised : Color.surface
        }
    }

    fileprivate static func describePace(of goal: CatchStatistics.Goal) -> String {
        if goal.isReached {
            return "Goal reached"
        }
        if goal.aheadOfPace > 0 {
            return "\(goal.aheadOfPace.grouped) ahead of pace"
        }
        if goal.aheadOfPace < 0 {
            return "\((-goal.aheadOfPace).grouped) behind pace"
        }
        return "Right on pace"
    }

    @objc fileprivate func tapped() {
        onTap()
    }
}
