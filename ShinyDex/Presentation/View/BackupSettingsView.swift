import UIKit

class BackupSettingsView: UIView {
    let exportRow = BackupActionRow(title: "Export backup", description: "Save catches, hunts, journeys and bingo boards to a file", symbolName: "square.and.arrow.up")
    let restoreRow = BackupActionRow(title: "Restore from backup", description: "Replace all current data with a backup file", symbolName: "arrow.counterclockwise")

    init() {
        super.init(frame: .zero)
        let header = SectionHeaderLabel()
        header.text = "BACKUP"
        let card = SettingsCard()
        card.stack.addArrangedSubview(exportRow)
        card.stack.addArrangedSubview(BackupSettingsView.makeSeparator())
        card.stack.addArrangedSubview(restoreRow)

        let stack = UIStackView(arrangedSubviews: [header, card])
        stack.axis = .vertical
        stack.spacing = 6
        addAutoLayoutSubviews(stack)
        stack.pinEdges(to: self, insets: UIEdgeInsets(top: 0, left: 8, bottom: 24, right: 8))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate static func makeSeparator() -> UIView {
        let line = UIView()
        let hairline = UIView()
        hairline.backgroundColor = Color.Grey700
        line.addAutoLayoutSubviews(hairline)
        NSLayoutConstraint.activate([
            line.heightAnchor.constraint(equalToConstant: 1),
            hairline.topAnchor.constraint(equalTo: line.topAnchor),
            hairline.bottomAnchor.constraint(equalTo: line.bottomAnchor),
            hairline.leadingAnchor.constraint(equalTo: line.leadingAnchor, constant: 60),
            hairline.trailingAnchor.constraint(equalTo: line.trailingAnchor)
        ])
        return line
    }
}

class BackupActionRow: UIControl {
    fileprivate let iconImageView = UIImageView()
    fileprivate let titleLabel = UILabel(fontSize: 17, weight: .semibold, color: Color.Grey200)
    fileprivate let descriptionLabel = UILabel(fontSize: 13, color: Color.Grey400, lines: 0)

    init(title: String, description: String, symbolName: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        descriptionLabel.text = description
        iconImageView.image = UIImage.makeSymbol(symbolName, pointSize: 20, weight: .medium)
        iconImageView.tintColor = Color.Orange500
        iconImageView.contentMode = .center
        let chevron = UIImageView(image: UIImage.makeSymbol("chevron.right", pointSize: 13, weight: .semibold))
        chevron.tintColor = Color.Grey500
        chevron.setContentHuggingPriority(.required, for: .horizontal)

        let labels = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel])
        labels.axis = .vertical
        labels.spacing = 2
        let row = UIStackView(arrangedSubviews: [iconImageView, labels, chevron])
        row.alignment = .center
        row.spacing = 12
        row.isUserInteractionEnabled = false
        addAutoLayoutSubviews(row)
        row.pinEdges(to: self, insets: UIEdgeInsets(top: 12, left: 14, bottom: 12, right: 14))
        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 34),
            iconImageView.heightAnchor.constraint(equalToConstant: 34)
        ])

        isAccessibilityElement = true
        accessibilityTraits = .button
        accessibilityLabel = title
        accessibilityHint = description
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isHighlighted: Bool {
        didSet { backgroundColor = isHighlighted ? Color.Grey700 : .clear }
    }
}
