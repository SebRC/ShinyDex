import UIKit

class MoveCell: UITableViewCell {
    static let moveReuseIdentifier = "moveCell"
    fileprivate static let buttonSize: CGFloat = 50
    fileprivate static let symbolSize: CGFloat = 34

    var onIncrement: (() -> Void)?
    var onDecrement: (() -> Void)?

    let decrementButton = UIButton.makeSymbolButton("minus.circle.fill", pointSize: MoveCell.symbolSize)
    let incrementButton = UIButton.makeSymbolButton("plus.circle.fill", pointSize: MoveCell.symbolSize)
    fileprivate let typeIconView = TypeIconView(size: 36)
    fileprivate let nameLabel = UILabel(fontSize: 19, weight: .semibold, lines: 2)
    fileprivate let typeLabel = UILabel(fontSize: 15, color: Color.Grey400)
    fileprivate let ppLabel = UILabel(fontSize: 15, weight: .semibold)
    fileprivate let ppBar = UIProgressView(progressViewStyle: .default)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = Color.Grey800
        let selectedBackground = UIView()
        selectedBackground.backgroundColor = Color.Grey700
        selectedBackgroundView = selectedBackground
        decrementButton.addTarget(self, action: #selector(decrementPressed), for: .touchUpInside)
        incrementButton.addTarget(self, action: #selector(incrementPressed), for: .touchUpInside)
        ppLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 15, weight: .semibold)
        ppLabel.setContentHuggingPriority(.required, for: .horizontal)
        ppLabel.textAlignment = .right
        ppBar.trackTintColor = Color.Grey700
        ppBar.layer.cornerRadius = 3
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
        nameLabel.text = move.name
        typeLabel.text = move.type
        typeIconView.setType(move.type)
        ppLabel.text = "\(move.remainingPP)/\(move.maxPP) PP"

        let fraction = move.maxPP > 0 ? min(1, Float(move.remainingPP) / Float(move.maxPP)) : 0
        ppBar.progress = fraction
        let stateColor: UIColor = move.remainingPP == 0 ? Color.Danger400 : (fraction <= 0.25 ? Color.Orange500 : Color.Grey200)
        ppLabel.textColor = stateColor
        ppBar.progressTintColor = move.remainingPP == 0 ? Color.Danger400 : (fraction <= 0.25 ? Color.Orange500 : Color.Success500)

        incrementButton.isEnabled = move.remainingPP < move.maxPP
        decrementButton.isEnabled = move.remainingPP > 0
        incrementButton.accessibilityLabel = "Restore PP for \(move.name)"
        decrementButton.accessibilityLabel = "Use \(move.name)"
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
