import UIKit

final class BattlerCell: UITableViewCell {
    static let reuseIdentifier = "battlerCell"
    fileprivate static let lessRelevantAlpha: CGFloat = 0.45

    fileprivate let rankLabel = UILabel(style: .footnote, weight: .bold, color: Color.textTertiary)
    fileprivate let sprite = UIImageView()
    fileprivate let titleLabel = UILabel(style: .body, weight: .semibold)
    fileprivate let detailsLabel = UILabel(style: .footnote, color: Color.textTertiary, lines: 0)
    fileprivate let scoreLabel = UILabel(style: .title2, weight: .bold, color: Color.accent)
    fileprivate let scoreCaptionLabel = UILabel(style: .caption2, weight: .semibold, color: Color.textTertiary)
    fileprivate let statColumns = UIStackView()
    fileprivate let badgesLabel = UILabel(style: .caption1, lines: 0)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = Color.surface
        let selectedBackground = UIView()
        selectedBackground.backgroundColor = Color.surfaceRaised
        selectedBackgroundView = selectedBackground

        sprite.contentMode = .scaleAspectFit
        sprite.layer.magnificationFilter = .nearest
        rankLabel.font = UIFont.make(.footnote, weight: .bold, monospacedDigits: true)
        rankLabel.textAlignment = .center
        rankLabel.setContentHuggingPriority(.required, for: .horizontal)
        scoreLabel.font = UIFont.make(.title2, weight: .bold, monospacedDigits: true)
        scoreLabel.textAlignment = .right
        scoreCaptionLabel.textAlignment = .right
        for label in [scoreLabel, scoreCaptionLabel] {
            label.setContentCompressionResistancePriority(.required, for: .horizontal)
            label.setContentHuggingPriority(.required, for: .horizontal)
        }

        let names = UIStackView(arrangedSubviews: [titleLabel, detailsLabel])
        names.axis = .vertical
        names.spacing = 2
        let score = UIStackView(arrangedSubviews: [scoreLabel, scoreCaptionLabel])
        score.axis = .vertical
        score.alignment = .trailing
        let identity = UIStackView(arrangedSubviews: [rankLabel, sprite, names, score])
        identity.alignment = .center
        identity.spacing = Spacing.small
        identity.setCustomSpacing(Spacing.extraSmall, after: rankLabel)

        statColumns.distribution = .fillEqually
        statColumns.backgroundColor = Color.surfaceRaised
        statColumns.layer.cornerRadius = CornerRadius.small
        statColumns.isLayoutMarginsRelativeArrangement = true
        statColumns.directionalLayoutMargins = NSDirectionalEdgeInsets(top: Spacing.small, leading: Spacing.extraSmall, bottom: Spacing.small, trailing: Spacing.extraSmall)

        let layout = UIStackView(arrangedSubviews: [identity, statColumns, badgesLabel])
        layout.axis = .vertical
        layout.spacing = Spacing.small
        contentView.addAutoLayoutSubviews(layout)
        layout.pinEdges(to: contentView, insets: UIEdgeInsets(top: Spacing.medium, left: Spacing.medium, bottom: Spacing.medium, right: Spacing.medium))
        NSLayoutConstraint.activate([
            rankLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 24),
            sprite.widthAnchor.constraint(equalToConstant: 52),
            sprite.heightAnchor.constraint(equalToConstant: 52)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(battler: BattlerSummary, rank: Int, ranking: BattlerRanking, level: BattleLevel) {
        rankLabel.text = "\(rank)"
        sprite.image = PokemonSprites.makeImage(pokemonName: battler.pokemonName, formId: battler.formId)
        titleLabel.text = battler.title
        detailsLabel.attributedText = battler.makeDetails(textColor: Color.textTertiary, font: UIFont.make(.footnote))
        scoreLabel.text = battler.formatScore(for: ranking)
        scoreCaptionLabel.text = ranking.scoreCaption
        rebuildStatColumns(for: battler)
        badgesLabel.attributedText = battler.makeBadgeText(font: UIFont.make(.caption1, weight: .semibold))
        badgesLabel.isHidden = badgesLabel.attributedText?.length == 0
        accessibilityLabel = makeAccessibilityLabel(for: battler, rank: rank, ranking: ranking, level: level)
    }

    fileprivate func rebuildStatColumns(for battler: BattlerSummary) {
        statColumns.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for stat in battler.stats {
            statColumns.addArrangedSubview(makeColumn(for: stat, nature: battler.nature))
        }
        statColumns.isAccessibilityElement = false
    }

    fileprivate func makeColumn(for stat: BattlerStat, nature: Nature?) -> UIView {
        let nameLabel = UILabel(style: .caption2, weight: .semibold, color: Color.textTertiary)
        nameLabel.attributedText = makeStatName(for: stat.stat, nature: nature)
        let ivLabel = UILabel(style: .subheadline, weight: .bold)
        ivLabel.font = UIFont.make(.subheadline, weight: .bold, monospacedDigits: true)
        ivLabel.text = stat.iv.map(String.init) ?? "?"
        ivLabel.textColor = stat.iv.map(IndividualValues.getColor(for:)) ?? Color.textQuaternary
        let valueLabel = UILabel(style: .caption1, color: Color.textSecondary)
        valueLabel.font = UIFont.make(.caption1, monospacedDigits: true)
        valueLabel.text = stat.value.map(String.init) ?? "–"
        let column = UIStackView(arrangedSubviews: [nameLabel, ivLabel, valueLabel])
        column.axis = .vertical
        column.alignment = .center
        column.spacing = 1
        column.alpha = stat.isLessRelevant ? BattlerCell.lessRelevantAlpha : 1
        return column
    }

    fileprivate func makeStatName(for stat: Stat, nature: Nature?) -> NSAttributedString {
        let name = NSMutableAttributedString(string: stat.shortName)
        switch stat {
        case nature?.raisedStat:
            name.append(NSAttributedString(string: "+", attributes: [.foregroundColor: Color.success]))
        case nature?.loweredStat:
            name.append(NSAttributedString(string: "−", attributes: [.foregroundColor: Color.danger]))
        default:
            break
        }
        return name
    }

    fileprivate func makeAccessibilityLabel(for battler: BattlerSummary, rank: Int, ranking: BattlerRanking, level: BattleLevel) -> String {
        let stats = battler.stats.map { stat in
            let iv = stat.iv.map { "IV \($0)" } ?? "IV unknown"
            let value = stat.value.map { ", \($0) at level \(level.rawValue)" } ?? ""
            return "\(stat.stat.name) \(iv)\(value)\(stat.isLessRelevant ? ", less relevant" : "")"
        }
        let parts = ["Rank \(rank)", battler.title, "\(ranking.scoreCaption.lowercased()) \(battler.formatScore(for: ranking))", battler.makeDetails(textColor: .clear, font: UIFont.make(.footnote)).string]
            + stats + battler.badges.map { $0.title }
        return parts.joined(separator: ", ")
    }
}
