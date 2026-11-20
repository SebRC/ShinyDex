import UIKit

struct UsageRow {
    let title: String
    let image: UIImage?
    let count: Int
    let filter: CollectionFilter
}

final class UsageRowView: UIControl {
    var onTap: (() -> Void)?

    init(row: UsageRow, maxCount: Int, total: Int) {
        super.init(frame: .zero)
        let icon = UIImageView(image: row.image)
        icon.contentMode = .scaleAspectFit
        icon.layer.magnificationFilter = .nearest
        let titleLabel = UILabel(fontSize: 15, weight: .medium)
        titleLabel.text = row.title
        let countLabel = UILabel(fontSize: 13, weight: .semibold, color: Color.Grey300)
        countLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 13, weight: .semibold)
        let percent = total > 0 ? Int((Double(row.count) / Double(total) * 100).rounded()) : 0
        countLabel.text = "\(row.count) · \(percent)%"
        countLabel.setContentHuggingPriority(.required, for: .horizontal)
        countLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        let track = UIView()
        track.backgroundColor = Color.Grey700
        track.layer.cornerRadius = 3
        let fill = UIView()
        fill.backgroundColor = Color.Orange500
        fill.layer.cornerRadius = 3
        track.addAutoLayoutSubviews(fill)

        let titleRow = UIStackView(arrangedSubviews: [titleLabel, countLabel])
        titleRow.spacing = 8
        let labels = UIStackView(arrangedSubviews: [titleRow, track])
        labels.axis = .vertical
        labels.spacing = 6
        let chevron = UIImageView(image: UIImage.makeSymbol("chevron.right", pointSize: 12, weight: .semibold))
        chevron.tintColor = Color.Grey500
        chevron.setContentHuggingPriority(.required, for: .horizontal)
        let layout = UIStackView(arrangedSubviews: [icon, labels, chevron])
        layout.alignment = .center
        layout.spacing = 10
        layout.isUserInteractionEnabled = false
        addAutoLayoutSubviews(layout)
        layout.pinEdges(to: self, insets: UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12))
        addTarget(self, action: #selector(tapped), for: .touchUpInside)
        NSLayoutConstraint.activate([
            icon.widthAnchor.constraint(equalToConstant: 34),
            icon.heightAnchor.constraint(equalToConstant: 34),
            track.heightAnchor.constraint(equalToConstant: 6),
            fill.leadingAnchor.constraint(equalTo: track.leadingAnchor),
            fill.topAnchor.constraint(equalTo: track.topAnchor),
            fill.bottomAnchor.constraint(equalTo: track.bottomAnchor),
            fill.widthAnchor.constraint(equalTo: track.widthAnchor, multiplier: CGFloat(row.count) / CGFloat(max(1, maxCount)))
        ])
        isAccessibilityElement = true
        accessibilityTraits = .button
        accessibilityLabel = "\(row.title), \(row.count) \(row.count == 1 ? "catch" : "catches"), \(percent) percent"
        accessibilityHint = "Shows these catches in your collection."
    }

    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? Color.Grey700 : .clear
        }
    }

    @objc fileprivate func tapped() {
        onTap?()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
