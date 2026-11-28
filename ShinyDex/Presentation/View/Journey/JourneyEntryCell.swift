import UIKit

final class JourneyEntryCell: UITableViewCell {
    static let reuseIdentifier = "journeyEntryCell"

    fileprivate let sprite = UIImageView()
    fileprivate let nameLabel = UILabel(style: .body, weight: .semibold)
    fileprivate let statusLabel = UILabel(style: .footnote, color: Color.textTertiary)
    fileprivate let suggestionLabel = UILabel(style: .footnote, color: Color.textSecondary, lines: 0)
    fileprivate let phasesButton = UIButton(type: .system)
    fileprivate let ballView = UIImageView()
    fileprivate let statusIcon = UIImageView()
    fileprivate var phaseCount = 0
    var onPhasesTapped: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = Color.surface
        let selectedBackground = UIView()
        selectedBackground.backgroundColor = Color.surfaceRaised
        selectedBackgroundView = selectedBackground
        sprite.contentMode = .scaleAspectFit
        sprite.layer.magnificationFilter = .nearest
        ballView.contentMode = .scaleAspectFit
        ballView.layer.magnificationFilter = .nearest
        statusIcon.contentMode = .center
        statusIcon.setContentHuggingPriority(.required, for: .horizontal)

        let statusRow = UIStackView(arrangedSubviews: [ballView, statusLabel])
        statusRow.spacing = 4
        statusRow.alignment = .center
        phasesButton.titleLabel?.font = UIFont.make(.footnote, weight: .semibold)
        phasesButton.tintColor = Color.accent
        phasesButton.semanticContentAttribute = .forceRightToLeft
        phasesButton.contentHorizontalAlignment = .leading
        phasesButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: -4)
        phasesButton.contentEdgeInsets = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 4)
        phasesButton.addTarget(self, action: #selector(phasesPressed), for: .touchUpInside)
        let labels = UIStackView(arrangedSubviews: [nameLabel, statusRow, suggestionLabel, phasesButton])
        labels.alignment = .leading
        labels.axis = .vertical
        labels.spacing = 2
        let row = UIStackView(arrangedSubviews: [sprite, labels, statusIcon])
        row.alignment = .center
        row.spacing = 12
        contentView.addAutoLayoutSubviews(row)
        NSLayoutConstraint.activate([
            row.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            row.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            row.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            row.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            sprite.widthAnchor.constraint(equalToConstant: 56),
            sprite.heightAnchor.constraint(equalToConstant: 56),
            ballView.widthAnchor.constraint(equalToConstant: 16),
            ballView.heightAnchor.constraint(equalToConstant: 16),
            statusIcon.widthAnchor.constraint(equalToConstant: 28)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(entry: JourneyEntryDetails, phasesExpanded: Bool) {
        let linked = entry.linkedCatch
        let linkableCount = entry.linkableCatchCount
        let name = entry.pokemonName.map { PokemonSprites.makeTitle(pokemonName: $0, formName: entry.formName) } ?? "Unknown"
        sprite.image = entry.pokemonName.flatMap { PokemonSprites.makeImage(pokemonName: $0, formId: entry.formId) }
        nameLabel.text = name
        sprite.alpha = linked == nil ? 0.4 : 1
        nameLabel.textColor = linked == nil ? Color.textSecondary : Color.textPrimary

        if let linked = linked {
            var parts = [linked.ballName, linked.game.displayName]
            if let date = linked.formattedCaughtDate {
                parts.append(date)
            }
            if (linked.number != entry.number) {
                parts.insert("as \(linked.pokemonName)", at: 0)
            }
            statusLabel.text = parts.joined(separator: " · ")
            statusLabel.textColor = Color.textTertiary
            ballView.image = UIImage(named: linked.caughtBall)
            ballView.isHidden = false
            statusIcon.image = UIImage.makeSymbol("checkmark.seal.fill", pointSize: 22, weight: .semibold)
            statusIcon.tintColor = Color.accent
        }
        else {
            statusLabel.text = linkableCount == 0 ? "Not caught yet" : (linkableCount == 1 ? "Not linked · 1 catch you can link" : "Not linked · \(linkableCount) catches you can link")
            statusLabel.textColor = linkableCount == 0 ? Color.textQuaternary : Color.textSecondary
            ballView.isHidden = true
            statusIcon.image = UIImage.makeSymbol(linkableCount == 0 ? "circle" : "link", pointSize: 18, weight: .semibold)
            statusIcon.tintColor = Color.textQuaternary
        }
        suggestionLabel.text = entry.suggestion.map { "Suggested: \(HuntSuggestionText.describeWithArea($0))" }
            ?? entry.missingFromGame.map { "Can't be obtained for \($0.displayName)" }
        suggestionLabel.textColor = entry.suggestion == nil ? Color.textQuaternary : Color.textSecondary
        suggestionLabel.isHidden = linked != nil || suggestionLabel.text == nil
        phaseCount = entry.phases.count
        phasesButton.setTitle(phaseCount == 1 ? "1 phase" : "\(phaseCount) phases", for: .normal)
        phasesButton.isHidden = phaseCount == 0
        setPhasesExpanded(phasesExpanded)
        accessibilityLabel = ["\(name), \(linked == nil ? "" : "caught, ")\(statusLabel.text ?? "")", suggestionLabel.isHidden ? nil : suggestionLabel.text,
                              phaseCount == 0 ? nil : phasesButton.currentTitle].compactMap { $0 }.joined(separator: ", ")
        accessibilityTraits = .button
    }

    func setPhasesExpanded(_ expanded: Bool) {
        phasesButton.setImage(UIImage.makeSymbol(expanded ? "chevron.up" : "chevron.down", pointSize: 11, weight: .bold), for: .normal)
        let toggleTitle = expanded ? "Hide phases" : "Show phases"
        phasesButton.accessibilityLabel = toggleTitle
        accessibilityCustomActions = phaseCount == 0 ? nil : [UIAccessibilityCustomAction(name: toggleTitle) { [weak self] _ in
            self?.onPhasesTapped?()
            return true
        }]
    }

    @objc fileprivate func phasesPressed() {
        onPhasesTapped?()
    }
}
