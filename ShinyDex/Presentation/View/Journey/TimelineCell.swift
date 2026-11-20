import UIKit

final class TimelineCell: UITableViewCell {
    static let reuseIdentifier = "timelineCell"

    fileprivate let topRail = UIView()
    fileprivate let bottomRail = UIView()
    fileprivate let dot = UILabel(fontSize: 12, weight: .bold, color: Color.Grey900)
    fileprivate let dateLabel = UILabel(fontSize: 13, weight: .semibold, color: Color.Orange500)
    fileprivate let gapLabel = UILabel(fontSize: 12, color: Color.Grey500)
    fileprivate let sprite = UIImageView()
    fileprivate let nameLabel = UILabel(fontSize: 17, weight: .semibold)
    fileprivate let detailLabel = UILabel(fontSize: 13, color: Color.Grey400)
    fileprivate let ballView = UIImageView()

    fileprivate static let dotSize: CGFloat = 24

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = Color.Grey800
        let selectedBackground = UIView()
        selectedBackground.backgroundColor = Color.Grey700
        selectedBackgroundView = selectedBackground
        for rail in [topRail, bottomRail] {
            rail.backgroundColor = Color.Grey600
        }
        dot.backgroundColor = Color.Orange500
        dot.textAlignment = .center
        dot.font = UIFont.monospacedDigitSystemFont(ofSize: 12, weight: .bold)
        dot.layer.cornerRadius = TimelineCell.dotSize / 2
        dot.clipsToBounds = true
        sprite.contentMode = .scaleAspectFit
        sprite.layer.magnificationFilter = .nearest
        ballView.contentMode = .scaleAspectFit
        ballView.layer.magnificationFilter = .nearest
        detailLabel.numberOfLines = 0

        dateLabel.setContentHuggingPriority(.required, for: .horizontal)
        gapLabel.setContentHuggingPriority(.required, for: .horizontal)
        let dateRow = UIStackView(arrangedSubviews: [dateLabel, gapLabel, UIView()])
        dateRow.spacing = 6
        dateRow.alignment = .firstBaseline
        let labels = UIStackView(arrangedSubviews: [dateRow, nameLabel, detailLabel])
        labels.axis = .vertical
        labels.spacing = 2
        let content = UIStackView(arrangedSubviews: [labels, sprite])
        content.alignment = .center
        content.spacing = 8

        contentView.addAutoLayoutSubviews(topRail, bottomRail, dot, content, ballView)
        NSLayoutConstraint.activate([
            dot.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dot.widthAnchor.constraint(equalToConstant: TimelineCell.dotSize),
            dot.heightAnchor.constraint(equalToConstant: TimelineCell.dotSize),
            dot.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            topRail.centerXAnchor.constraint(equalTo: dot.centerXAnchor),
            topRail.widthAnchor.constraint(equalToConstant: 2),
            topRail.topAnchor.constraint(equalTo: contentView.topAnchor),
            topRail.bottomAnchor.constraint(equalTo: dot.topAnchor),
            bottomRail.centerXAnchor.constraint(equalTo: dot.centerXAnchor),
            bottomRail.widthAnchor.constraint(equalToConstant: 2),
            bottomRail.topAnchor.constraint(equalTo: dot.bottomAnchor),
            bottomRail.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            content.leadingAnchor.constraint(equalTo: dot.trailingAnchor, constant: 14),
            content.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            content.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            content.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            sprite.widthAnchor.constraint(equalToConstant: 64),
            sprite.heightAnchor.constraint(equalToConstant: 64),
            ballView.widthAnchor.constraint(equalToConstant: 20),
            ballView.heightAnchor.constraint(equalToConstant: 20),
            ballView.trailingAnchor.constraint(equalTo: sprite.trailingAnchor),
            ballView.bottomAnchor.constraint(equalTo: sprite.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(catchNumber: Int?, step: JourneyTimelineStep, previousDate: Date?, isFirst: Bool, isLast: Bool) {
        let caught = step.caught
        if let catchNumber = catchNumber {
            dot.font = UIFont.monospacedDigitSystemFont(ofSize: 12, weight: .bold)
            dot.text = "\(catchNumber)"
            dot.backgroundColor = Color.Orange500
        }
        else {
            let sparkle = UIImage.makeSymbol("sparkle", pointSize: 11, weight: .bold)?.withTintColor(Color.Grey900, renderingMode: .alwaysOriginal)
            dot.attributedText = sparkle.map { NSAttributedString(attachment: NSTextAttachment(image: $0)) }
            dot.backgroundColor = Color.Grey500
        }
        dot.textAlignment = .center
        topRail.isHidden = isFirst
        bottomRail.isHidden = isLast
        dateLabel.text = caught.formattedCaughtDate ?? "Undated"
        gapLabel.text = TimelineCell.formatGap(from: previousDate, to: caught.caughtDate)
        gapLabel.isHidden = gapLabel.text == nil
        let name = caught.pokemonName
        nameLabel.text = name
        sprite.image = UIImage(named: name.lowercased())
        ballView.image = UIImage(named: caught.caughtBall)
        ballView.isHidden = caught.isFailed
        let outcome = caught.isFailed ? "Got away" : caught.ballName
        let details = "\(caught.encounters.grouped) encounters\n\(outcome) · \(caught.game.displayName)"
        detailLabel.text = step.isPhase ? "Phase while hunting \(step.entryPokemonName ?? "Unknown")\n\(details)" : details
        let stepTitle = catchNumber.map { "Catch \($0)" } ?? "Phase"
        accessibilityLabel = "\(stepTitle), \(name), \(dateLabel.text ?? ""), \(gapLabel.text ?? ""), \(detailLabel.text ?? "")"
        accessibilityTraits = .button
    }

    fileprivate static func formatGap(from previous: Date?, to date: Date?) -> String? {
        guard let previous = previous, let date = date else { return nil }
        let days = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: previous), to: Calendar.current.startOfDay(for: date)).day ?? 0
        switch days {
        case 0: return "same day"
        case 1: return "+1 day"
        default: return "+\(days.grouped) days"
        }
    }
}
