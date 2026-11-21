import UIKit

final class PhaseCell: UITableViewCell {
    static let reuseIdentifier = "journeyPhaseCell"

    fileprivate let connector = UIView()
    fileprivate let sprite = UIImageView()
    fileprivate let titleLabel = UILabel(style: .subheadline, weight: .semibold)
    fileprivate let subtitleLabel = UILabel(style: .caption1, color: Color.textTertiary)
    fileprivate let outcomeView = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = Color.surface
        let selectedBackground = UIView()
        selectedBackground.backgroundColor = Color.surfaceRaised
        selectedBackgroundView = selectedBackground
        accessoryType = .disclosureIndicator
        separatorInset = UIEdgeInsets(top: 0, left: 76, bottom: 0, right: 0)
        connector.backgroundColor = Color.inactive
        for imageView in [sprite, outcomeView] {
            imageView.contentMode = .scaleAspectFit
            imageView.layer.magnificationFilter = .nearest
        }

        let labels = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        labels.axis = .vertical
        labels.spacing = 1
        let row = UIStackView(arrangedSubviews: [sprite, labels, outcomeView])
        row.alignment = .center
        row.spacing = 8
        contentView.addAutoLayoutSubviews(connector, row)
        NSLayoutConstraint.activate([
            connector.centerXAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 36),
            connector.topAnchor.constraint(equalTo: contentView.topAnchor),
            connector.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            connector.widthAnchor.constraint(equalToConstant: 2),
            row.leadingAnchor.constraint(equalTo: connector.trailingAnchor, constant: 12),
            row.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            row.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            row.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            sprite.widthAnchor.constraint(equalToConstant: 40),
            sprite.heightAnchor.constraint(equalToConstant: 40),
            outcomeView.widthAnchor.constraint(equalToConstant: 24),
            outcomeView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(phase: CatchSummary) {
        sprite.image = phase.spriteImage
        sprite.alpha = phase.isFailed ? 0.55 : 1
        titleLabel.text = [phase.nickname, phase.speciesTitle].compactMap { $0 }.joined(separator: " · ")
        titleLabel.textColor = phase.isFailed ? Color.textSecondary : Color.textPrimary
        let outcome = phase.isFailed ? "Got away" : phase.ballName
        subtitleLabel.text = [outcome, "\(phase.encounters.grouped) encounters", phase.formattedCaughtDate].compactMap { $0 }.joined(separator: " · ")
        outcomeView.image = phase.isFailed ? UIImage.makeSymbol("wind", pointSize: 15, weight: .semibold) : UIImage(named: phase.caughtBall)
        outcomeView.tintColor = Color.textQuaternary
        outcomeView.contentMode = phase.isFailed ? .center : .scaleAspectFit
        accessibilityLabel = "Phase, \(titleLabel.text ?? ""), \(subtitleLabel.text ?? "")"
    }
}
