import UIKit

final class StatLeaderCell: UITableViewCell {
    static let reuseIdentifier = "statLeaderCell"

    fileprivate let rankLabel = UILabel(style: .footnote, weight: .bold, color: Color.textTertiary)
    fileprivate let sprite = UIImageView()
    fileprivate let titleLabel = UILabel(style: .body, weight: .semibold)
    fileprivate let detailsLabel = UILabel(style: .footnote, color: Color.textTertiary, lines: 0)
    fileprivate let trainingLabel = UILabel(style: .footnote, weight: .semibold, color: Color.accent, lines: 0)
    fileprivate let valueLabel = UILabel(style: .title2, weight: .bold, color: Color.textPrimary)
    fileprivate let valueCaptionLabel = UILabel(style: .caption2, weight: .semibold, color: Color.textTertiary)

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
        valueLabel.font = UIFont.make(.title2, weight: .bold, monospacedDigits: true)
        valueLabel.textAlignment = .right
        valueCaptionLabel.textAlignment = .right
        for label in [rankLabel, valueLabel, valueCaptionLabel] {
            label.setContentCompressionResistancePriority(.required, for: .horizontal)
            label.setContentHuggingPriority(.required, for: .horizontal)
        }

        let names = UIStackView(arrangedSubviews: [titleLabel, detailsLabel, trainingLabel])
        names.axis = .vertical
        names.spacing = 2
        let value = UIStackView(arrangedSubviews: [valueLabel, valueCaptionLabel])
        value.axis = .vertical
        value.alignment = .trailing
        let layout = UIStackView(arrangedSubviews: [rankLabel, sprite, names, value])
        layout.alignment = .center
        layout.spacing = Spacing.small
        layout.setCustomSpacing(Spacing.extraSmall, after: rankLabel)
        contentView.addAutoLayoutSubviews(layout)
        layout.pinEdges(to: contentView, insets: UIEdgeInsets(top: Spacing.small, left: Spacing.medium, bottom: Spacing.small, right: Spacing.medium))
        NSLayoutConstraint.activate([
            rankLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 24),
            sprite.widthAnchor.constraint(equalToConstant: 48),
            sprite.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(leader: StatLeader, rank: Int, stat: Stat, level: BattleLevel) {
        rankLabel.text = "\(rank)"
        rankLabel.textColor = rank == 1 ? Color.accent : Color.textTertiary
        sprite.image = PokemonSprites.makeImage(pokemonName: leader.pokemonName, formId: leader.formId)
        let speciesTitle = PokemonSprites.makeTitle(pokemonName: leader.pokemonName, formName: leader.formName)
        titleLabel.text = leader.nickname ?? speciesTitle
        detailsLabel.text = StatLeaderCell.makeDetails(of: leader)
        valueLabel.text = "\(leader.value)"
        valueLabel.textColor = StatLeaderCell.findValueColor(for: stat, nature: leader.nature)
        valueCaptionLabel.text = stat.shortName.uppercased()
        trainingLabel.text = StatLeaderCell.makeTrainingText(of: leader)
        trainingLabel.isHidden = trainingLabel.text == nil
        accessibilityLabel = ["Rank \(rank)", titleLabel.text, "\(stat.name) \(leader.value) at level \(level.rawValue)", detailsLabel.text, trainingLabel.text].compactMap { $0 }.joined(separator: ", ")
    }

    fileprivate static func makeDetails(of leader: StatLeader) -> String {
        let nature = leader.nature.map { "\($0.name) (\($0.effectSummary))" } ?? "No nature"
        return [nature, "IV \(leader.iv)", "\(leader.ev) EVs"].joined(separator: " · ")
    }

    fileprivate static func makeTrainingText(of leader: StatLeader) -> String? {
        guard let trainedValue = leader.trainedValue else { return nil }
        let reach = "\(trainedValue) with EV training"
        return leader.trainedRank.map { "\(reach), enough for #\($0)" } ?? reach
    }

    fileprivate static func findValueColor(for stat: Stat, nature: Nature?) -> UIColor {
        switch stat {
        case nature?.raisedStat: return Color.success
        case nature?.loweredStat: return Color.danger
        default: return Color.textPrimary
        }
    }
}
