import UIKit

class HuntHeaderView: UITableViewHeaderFooterView, UIContextMenuInteractionDelegate {
    static let reuseIdentifier = "huntHeader"

    var onToggleCollapse: (() -> Void)?
    var onIncrementAll: (() -> Void)?
    var onRename: (() -> Void)?

    fileprivate let toggleControl = UIControl()
    fileprivate let chevronImageView = UIImageView(image: UIImage(systemName: "chevron.down"))
    fileprivate let nameLabel = UILabel()
    fileprivate let encountersLabel = UILabel()
    fileprivate let incrementAllButton = UIButton(type: .system)
    fileprivate var isCollapsed = false

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        let background = UIView()
        background.backgroundColor = Color.Grey900
        backgroundView = background

        chevronImageView.tintColor = Color.Orange500
        chevronImageView.contentMode = .scaleAspectFit
        chevronImageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(textStyle: .headline, scale: .medium)

        nameLabel.font = UIFont.preferredFont(forTextStyle: .title3).withWeight(.semibold)
        nameLabel.adjustsFontForContentSizeCategory = true
        nameLabel.textColor = Color.Grey200
        nameLabel.numberOfLines = 1

        encountersLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        encountersLabel.adjustsFontForContentSizeCategory = true
        encountersLabel.textColor = Color.Grey400

        let labels = UIStackView(arrangedSubviews: [nameLabel, encountersLabel])
        labels.axis = .vertical
        labels.spacing = 2
        labels.isUserInteractionEnabled = false

        let toggleContent = UIStackView(arrangedSubviews: [chevronImageView, labels])
        toggleContent.spacing = 12
        toggleContent.alignment = .center
        toggleContent.isUserInteractionEnabled = false
        toggleContent.translatesAutoresizingMaskIntoConstraints = false
        toggleControl.addSubview(toggleContent)
        toggleControl.addTarget(self, action: #selector(togglePressed), for: .touchUpInside)
        toggleControl.isAccessibilityElement = true
        toggleControl.accessibilityTraits = .button
        toggleControl.accessibilityHint = "Shows or hides the Pokémon in this hunt."

        var configuration = UIButton.Configuration.filled()
        configuration.baseBackgroundColor = Color.Orange500
        configuration.baseForegroundColor = Color.Grey900
        configuration.cornerStyle = .capsule
        configuration.image = UIImage.makeSymbol("plus", pointSize: 13, weight: .bold)
        configuration.imagePadding = 4
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 7, leading: 12, bottom: 7, trailing: 14)
        var title = AttributedString("All")
        title.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        configuration.attributedTitle = title
        incrementAllButton.configuration = configuration
        incrementAllButton.setContentHuggingPriority(.required, for: .horizontal)
        incrementAllButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        incrementAllButton.addTarget(self, action: #selector(incrementAllPressed), for: .touchUpInside)

        for subview in [toggleControl, incrementAllButton] {
            subview.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(subview)
        }
        let margins = contentView.layoutMarginsGuide
        NSLayoutConstraint.activate([
            toggleContent.topAnchor.constraint(equalTo: toggleControl.topAnchor, constant: 10),
            toggleContent.bottomAnchor.constraint(equalTo: toggleControl.bottomAnchor, constant: -10),
            toggleContent.leadingAnchor.constraint(equalTo: toggleControl.leadingAnchor),
            toggleContent.trailingAnchor.constraint(lessThanOrEqualTo: toggleControl.trailingAnchor),
            chevronImageView.widthAnchor.constraint(equalToConstant: 22),

            toggleControl.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            toggleControl.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            toggleControl.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            toggleControl.trailingAnchor.constraint(equalTo: incrementAllButton.leadingAnchor, constant: -8),

            incrementAllButton.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            incrementAllButton.centerYAnchor.constraint(equalTo: toggleControl.centerYAnchor),
            incrementAllButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 34)
        ])

        toggleControl.addInteraction(UIContextMenuInteraction(delegate: self))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(hunt: HuntSummary) {
        isCollapsed = hunt.isCollapsed
        nameLabel.text = hunt.name
        encountersLabel.text = HuntHeaderView.formatEncounters(hunt.totalEncounters, pokemonCount: hunt.members.count)
        chevronImageView.transform = isCollapsed ? CGAffineTransform(rotationAngle: -.pi / 2) : .identity
        toggleControl.accessibilityLabel = "\(hunt.name), \(encountersLabel.text ?? "")"
        toggleControl.accessibilityValue = isCollapsed ? "Collapsed" : "Expanded"
        incrementAllButton.accessibilityLabel = "Count an encounter for every Pokémon in \(hunt.name)"
        toggleControl.accessibilityCustomActions = [
            UIAccessibilityCustomAction(name: "Rename hunt") { [weak self] _ in
                self?.onRename?()
                return true
            }
        ]
    }

    static func formatEncounters(_ encounters: Int, pokemonCount: Int) -> String {
        let pokemonText = pokemonCount == 1 ? "1 Pokémon" : "\(pokemonCount) Pokémon"
        let encountersText = encounters == 1 ? "1 encounter" : "\(encounters.grouped) encounters"
        return "\(pokemonText) · \(encountersText)"
    }

    @objc fileprivate func togglePressed() {
        onToggleCollapse?()
    }

    @objc fileprivate func incrementAllPressed() {
        Haptics.playBulk()
        onIncrementAll?()
    }

    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            guard let self = self else { return nil }
            return UIMenu(children: [
                UIAction(title: "Rename", image: UIImage(systemName: "pencil")) { [weak self] _ in self?.onRename?() },
                UIAction(title: "Count encounter for all", image: UIImage(systemName: "plus")) { [weak self] _ in self?.incrementAllPressed() },
                UIAction(title: self.isCollapsed ? "Expand" : "Collapse",
                         image: UIImage(systemName: self.isCollapsed ? "chevron.down" : "chevron.right")) { [weak self] _ in self?.onToggleCollapse?() }
            ])
        }
    }
}

extension UIFont {
    func withWeight(_ weight: UIFont.Weight) -> UIFont {
        let descriptor = fontDescriptor.addingAttributes([.traits: [UIFontDescriptor.TraitKey.weight: weight]])
        return UIFont(descriptor: descriptor, size: 0)
    }
}
