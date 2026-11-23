import UIKit

final class AchievementCell: UITableViewCell {
    static let reuseIdentifier = "achievementCell"
    fileprivate static let iconDiameter: CGFloat = 44
    fileprivate static let tierDotDiameter: CGFloat = 8

    fileprivate let iconBackground = UIView()
    fileprivate let iconView = UIImageView()
    fileprivate let titleLabel = UILabel(style: .body, weight: .semibold)
    fileprivate let goalLabel = UILabel(style: .footnote, color: Color.textTertiary, lines: 0)
    fileprivate let progressBar = UIProgressView(progressViewStyle: .default)
    fileprivate let progressLabel = UILabel(style: .caption1, weight: .semibold, color: Color.textTertiary)
    fileprivate let progressRow = UIStackView()
    fileprivate let tierDots = UIStackView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = Color.surface
        let selectedBackground = UIView()
        selectedBackground.backgroundColor = Color.surfaceRaised
        selectedBackgroundView = selectedBackground

        iconBackground.layer.cornerRadius = CornerRadius.capsule(height: AchievementCell.iconDiameter)
        iconView.contentMode = .center
        iconBackground.addAutoLayoutSubviews(iconView)
        iconView.pinEdges(to: iconBackground)

        progressBar.trackTintColor = Color.surfaceRaised
        progressBar.progressTintColor = Color.accent
        progressBar.layer.cornerRadius = CornerRadius.tiny
        progressBar.clipsToBounds = true
        progressLabel.font = UIFont.make(.caption1, weight: .semibold, monospacedDigits: true)
        progressLabel.setContentHuggingPriority(.required, for: .horizontal)
        progressLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        [progressBar, progressLabel].forEach(progressRow.addArrangedSubview)
        progressRow.alignment = .center
        progressRow.spacing = Spacing.small

        tierDots.spacing = Spacing.extraSmall
        tierDots.alignment = .center
        tierDots.setContentHuggingPriority(.required, for: .horizontal)

        let titleRow = UIStackView(arrangedSubviews: [titleLabel, tierDots])
        titleRow.alignment = .center
        titleRow.spacing = Spacing.small
        let texts = UIStackView(arrangedSubviews: [titleRow, goalLabel, progressRow])
        texts.axis = .vertical
        texts.spacing = 2
        texts.setCustomSpacing(Spacing.small, after: goalLabel)
        let row = UIStackView(arrangedSubviews: [iconBackground, texts])
        row.alignment = .center
        row.spacing = Spacing.medium
        contentView.addAutoLayoutSubviews(row)
        row.pinEdges(to: contentView, insets: UIEdgeInsets(top: Spacing.medium, left: Spacing.large, bottom: Spacing.medium, right: Spacing.large))
        NSLayoutConstraint.activate([
            iconBackground.widthAnchor.constraint(equalToConstant: AchievementCell.iconDiameter),
            iconBackground.heightAnchor.constraint(equalToConstant: AchievementCell.iconDiameter),
            progressBar.heightAnchor.constraint(equalToConstant: 6)
        ])
        isAccessibilityElement = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(achievement: Achievement, showsDisclosure: Bool = false) {
        accessoryType = showsDisclosure && !achievement.isSecret ? .disclosureIndicator : .none
        accessibilityTraits = accessoryType == .none ? .none : .button
        guard !achievement.isSecret else {
            configureSecret()
            return
        }
        let isUnlocked = achievement.isUnlocked
        iconBackground.backgroundColor = isUnlocked ? Color.accentSubtle : Color.surfaceRaised
        iconView.image = UIImage.makeSymbol(achievement.symbolName, pointSize: 19, weight: .semibold)
        iconView.tintColor = isUnlocked ? Color.accent : Color.textQuaternary
        titleLabel.text = achievement.title
        titleLabel.textColor = isUnlocked ? Color.textPrimary : Color.textSecondary
        goalLabel.text = achievement.isComplete ? "Done · \(achievement.goal)" : achievement.goal
        let showsProgress = achievement.countsProgress && !achievement.isComplete
        progressRow.isHidden = !showsProgress
        if (showsProgress) {
            progressBar.progress = Float(achievement.value) / Float(max(achievement.currentTarget, 1))
            progressLabel.text = "\(achievement.value.grouped) / \(achievement.currentTarget.grouped)"
        }
        rebuildTierDots(unlocked: achievement.unlockedTierCount, total: achievement.targets.count)
        accessibilityLabel = makeAccessibilityLabel(for: achievement, showsProgress: showsProgress)
    }

    fileprivate func configureSecret() {
        iconBackground.backgroundColor = Color.surfaceRaised
        iconView.image = UIImage.makeSymbol("questionmark", pointSize: 19, weight: .semibold)
        iconView.tintColor = Color.textQuaternary
        titleLabel.text = "Secret achievement"
        titleLabel.textColor = Color.textSecondary
        goalLabel.text = "Keep hunting to find out."
        progressRow.isHidden = true
        rebuildTierDots(unlocked: 0, total: 0)
        accessibilityLabel = "Secret achievement, locked"
    }

    fileprivate func rebuildTierDots(unlocked: Int, total: Int) {
        tierDots.arrangedSubviews.forEach { $0.removeFromSuperview() }
        tierDots.isHidden = total < 2
        guard total > 1 else { return }
        for index in 0..<total {
            let dot = UIView()
            dot.backgroundColor = index < unlocked ? Color.accent : Color.surfaceRaised
            dot.layer.cornerRadius = CornerRadius.capsule(height: AchievementCell.tierDotDiameter)
            NSLayoutConstraint.activate([
                dot.widthAnchor.constraint(equalToConstant: AchievementCell.tierDotDiameter),
                dot.heightAnchor.constraint(equalToConstant: AchievementCell.tierDotDiameter)
            ])
            tierDots.addArrangedSubview(dot)
        }
    }

    fileprivate func makeAccessibilityLabel(for achievement: Achievement, showsProgress: Bool) -> String {
        let state: String
        if (achievement.targets.count > 1) {
            state = "\(achievement.unlockedTierCount) of \(achievement.targets.count) tiers"
        }
        else {
            state = achievement.isUnlocked ? "unlocked" : "locked"
        }
        let progress = showsProgress ? "\(achievement.value) of \(achievement.currentTarget)" : nil
        return [achievement.title, state, achievement.goal, progress].compactMap { $0 }.joined(separator: ", ")
    }
}
