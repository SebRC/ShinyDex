import UIKit

class MoveCell: UITableViewCell {
    static let moveReuseIdentifier = "moveCell"
    fileprivate static let buttonSize: CGFloat = 50
    fileprivate static let symbolSize: CGFloat = 34

    var onIncrement: (() -> Void)?
    var onDecrement: (() -> Void)?

    let decrementButton = UIButton.makeCounterButton(symbolName: "minus.circle.fill", role: .primary, pointSize: MoveCell.symbolSize)
    let incrementButton = UIButton.makeCounterButton(symbolName: "plus.circle.fill", role: .secondary, pointSize: MoveCell.symbolSize)
    fileprivate let typeIconView = TypeIconView(size: 36)
    fileprivate let nameLabel = UILabel(style: .body, weight: .semibold, lines: 2)
    fileprivate let typeLabel = UILabel(style: .subheadline, color: Color.textTertiary)
    fileprivate let ppLabel = UILabel(style: .subheadline, weight: .semibold)
    fileprivate let ppBar = UIProgressView(progressViewStyle: .default)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = Color.surface
        let selectedBackground = UIView()
        selectedBackground.backgroundColor = Color.surfaceRaised
        selectedBackgroundView = selectedBackground
        decrementButton.addTarget(self, action: #selector(decrementPressed), for: .touchUpInside)
        incrementButton.addTarget(self, action: #selector(incrementPressed), for: .touchUpInside)
        ppLabel.font = UIFont.make(.subheadline, weight: .semibold, monospacedDigits: true)
        ppLabel.setContentHuggingPriority(.required, for: .horizontal)
        ppLabel.textAlignment = .right
        ppBar.trackTintColor = Color.surfaceRaised
        ppBar.layer.cornerRadius = CornerRadius.tiny
        ppBar.clipsToBounds = true
        ppBar.isAccessibilityElement = false

        let titleLabels = UIStackView(arrangedSubviews: [nameLabel, typeLabel])
        titleLabels.axis = .vertical
        titleLabels.spacing = 2
        let titleRow = UIStackView(arrangedSubviews: [typeIconView, titleLabels])
        titleRow.alignment = .center
        titleRow.spacing = 12
        let ppRow = UIStackView(arrangedSubviews: [ppBar, ppLabel])
        ppRow.alignment = .center
        ppRow.spacing = 10
        let content = UIStackView(arrangedSubviews: [titleRow, ppRow])
        content.axis = .vertical
        content.spacing = 12

        let buttons = UIStackView(arrangedSubviews: [decrementButton, incrementButton])
        buttons.spacing = 4

        contentView.addAutoLayoutSubviews(content, buttons)
        NSLayoutConstraint.activate([
            content.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            content.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            content.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -14),
            content.trailingAnchor.constraint(equalTo: buttons.leadingAnchor, constant: -16),
            ppBar.heightAnchor.constraint(equalToConstant: 6),
            ppLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 76),

            buttons.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            buttons.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            decrementButton.widthAnchor.constraint(equalToConstant: MoveCell.buttonSize),
            decrementButton.heightAnchor.constraint(equalToConstant: MoveCell.buttonSize),
            incrementButton.widthAnchor.constraint(equalToConstant: MoveCell.buttonSize),
            incrementButton.heightAnchor.constraint(equalToConstant: MoveCell.buttonSize)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(move: MoveSlot) {
        let isPlaceholder = move.isPlaceholder
        [ppBar, ppLabel, decrementButton, incrementButton].forEach { $0.isHidden = isPlaceholder }
        typeIconView.isHidden = isPlaceholder
        nameLabel.textColor = isPlaceholder ? Color.textTertiary : Color.textPrimary
        nameLabel.text = isPlaceholder ? "Choose a move" : move.name
        typeLabel.text = isPlaceholder ? "Tap to pick one, or use a preset" : move.type
        typeIconView.setType(move.type)
        ppLabel.text = "\(move.remainingPP)/\(move.maxPP) PP"

        let fraction = move.maxPP > 0 ? min(1, Float(move.remainingPP) / Float(move.maxPP)) : 0
        ppBar.progress = fraction
        let stateColor: UIColor = move.remainingPP == 0 ? Color.danger : (fraction <= 0.25 ? Color.accent : Color.textPrimary)
        ppLabel.textColor = stateColor
        ppBar.progressTintColor = move.remainingPP == 0 ? Color.danger : (fraction <= 0.25 ? Color.accent : Color.success)

        incrementButton.isEnabled = move.remainingPP < move.maxPP
        decrementButton.isEnabled = move.remainingPP > 0
        incrementButton.accessibilityLabel = "Restore PP for \(move.name)"
        decrementButton.accessibilityLabel = "Use \(move.name)"
        guard !isPlaceholder else {
            accessibilityLabel = "Empty move slot. Tap to choose a move"
            accessibilityCustomActions = nil
            return
        }
        accessibilityLabel = "\(move.name), \(move.type), \(move.remainingPP) of \(move.maxPP) PP"
        accessibilityCustomActions = [
            UIAccessibilityCustomAction(name: "Use move", target: self, selector: #selector(decrementAction)),
            UIAccessibilityCustomAction(name: "Restore PP", target: self, selector: #selector(incrementAction))
        ]
    }

    @objc fileprivate func decrementPressed() {
        onDecrement?()
    }

    @objc fileprivate func incrementPressed() {
        onIncrement?()
    }

    @objc fileprivate func decrementAction() -> Bool {
        guard decrementButton.isEnabled else { return false }
        onDecrement?()
        return true
    }

    @objc fileprivate func incrementAction() -> Bool {
        guard incrementButton.isEnabled else { return false }
        onIncrement?()
        return true
    }
}
