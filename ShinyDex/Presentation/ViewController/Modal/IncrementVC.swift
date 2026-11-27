import UIKit

class IncrementVC: UIViewController, UITextFieldDelegate {
    fileprivate static let maximumIncrement = 100
    fileprivate static let presets = Array(1...6)

    fileprivate let container: AppContainer
    fileprivate let number: Int
    fileprivate let currentIncrement: Int
    fileprivate let onSave: () -> Void
    fileprivate var saveButton: UIBarButtonItem!

    fileprivate var presetTiles = [IncrementTile]()
    fileprivate let customTile = IncrementTile(valueText: "", label: "Custom", isWide: true)
    fileprivate let customCard = UIView()
    fileprivate let customField = UITextField()
    fileprivate let customMinus = UIButton(type: .system)
    fileprivate let customPlus = UIButton(type: .system)
    fileprivate let previewLabel = UILabel(style: .subheadline, weight: .semibold, color: Color.accent, lines: 0)

    fileprivate var selectedPresetIndex: Int?
    fileprivate var customValue = 7

    init(container: AppContainer, number: Int, increment: Int, onSave: @escaping () -> Void) {
        self.container = container
        self.number = number
        self.currentIncrement = increment
        self.onSave = onSave
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Encounters per tap"
        view.backgroundColor = Color.background
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelPressed))
        saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(confirmPressed))
        navigationItem.rightBarButtonItem = saveButton

        if let index = IncrementVC.presets.firstIndex(of: currentIncrement) {
            selectedPresetIndex = index
        }
        else {
            selectedPresetIndex = nil
            customValue = min(max(currentIncrement, 1), IncrementVC.maximumIncrement)
        }
        layOutViews()
        updateSelection()
    }

    // MARK: Layout

    fileprivate func layOutViews() {
        let scrollView = UIScrollView()
        scrollView.keyboardDismissMode = .onDrag
        scrollView.alwaysBounceVertical = true
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10

        for (index, preset) in IncrementVC.presets.enumerated() {
            let tile = IncrementTile(valueText: "\(preset)", label: preset == 1 ? "encounter" : "encounters", isWide: false)
            tile.tag = index
            tile.addTarget(self, action: #selector(presetPressed(_:)), for: .touchUpInside)
            presetTiles.append(tile)
        }
        for rowStart in stride(from: 0, to: presetTiles.count, by: 3) {
            let row = UIStackView(arrangedSubviews: Array(presetTiles[rowStart..<min(rowStart + 3, presetTiles.count)]))
            row.distribution = .fillEqually
            row.spacing = 10
            stack.addArrangedSubview(row)
        }
        customTile.addTarget(self, action: #selector(customPressed), for: .touchUpInside)
        stack.addArrangedSubview(customTile)
        setUpCustomCard()
        stack.addArrangedSubview(customCard)

        previewLabel.textAlignment = .center
        stack.setCustomSpacing(18, after: customCard)
        stack.addArrangedSubview(previewLabel)

        view.addAutoLayoutSubviews(scrollView)
        scrollView.pinEdges(to: view)
        scrollView.addAutoLayoutSubviews(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),
            stack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: Spacing.screenMargin),
            stack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -Spacing.screenMargin)
        ])
    }

    fileprivate func setUpCustomCard() {
        customCard.backgroundColor = Color.surface
        customCard.layer.cornerRadius = CornerRadius.standard
        for (button, symbol, label) in [(customMinus, "minus", "Decrease"), (customPlus, "plus", "Increase")] {
            button.setImage(UIImage.makeSymbol(symbol, pointSize: 20, weight: .bold), for: .normal)
            button.tintColor = Color.textPrimary
            button.backgroundColor = Color.surfaceRaised
            button.layer.cornerRadius = CornerRadius.capsule(height: 44)
            button.accessibilityLabel = label
            button.widthAnchor.constraint(equalToConstant: 56).isActive = true
            button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        }
        customMinus.addTarget(self, action: #selector(customMinusPressed), for: .touchUpInside)
        customPlus.addTarget(self, action: #selector(customPlusPressed), for: .touchUpInside)

        customField.delegate = self
        customField.keyboardType = .numberPad
        customField.textAlignment = .center
        customField.font = UIFont.make(.title1, weight: .bold, monospacedDigits: true)
        customField.textColor = Color.textPrimary
        customField.accessibilityLabel = "Custom encounters per tap"
        customField.addTarget(self, action: #selector(customFieldChanged), for: .editingChanged)

        let rangeLabel = UILabel(style: .caption1, color: Color.textQuaternary)
        rangeLabel.text = "1–\(IncrementVC.maximumIncrement)"
        rangeLabel.textAlignment = .center
        let fieldStack = UIStackView(arrangedSubviews: [customField, rangeLabel])
        fieldStack.axis = .vertical
        let row = UIStackView(arrangedSubviews: [customMinus, fieldStack, customPlus])
        row.alignment = .center
        row.spacing = 12
        customCard.addAutoLayoutSubviews(row)
        row.pinEdges(to: customCard, insets: UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12))
    }

    // MARK: Selection

    @objc fileprivate func presetPressed(_ sender: IncrementTile) {
        Haptics.tap()
        selectedPresetIndex = sender.tag
        view.endEditing(true)
        updateSelection()
    }

    @objc fileprivate func customPressed() {
        Haptics.tap()
        selectedPresetIndex = nil
        updateSelection()
    }

    @objc fileprivate func customMinusPressed() {
        setCustomValue((validCustomValue ?? customValue) - 1)
    }

    @objc fileprivate func customPlusPressed() {
        setCustomValue((validCustomValue ?? customValue) + 1)
    }

    fileprivate func setCustomValue(_ value: Int) {
        Haptics.tap()
        customValue = min(max(value, 1), IncrementVC.maximumIncrement)
        customField.text = "\(customValue)"
        updateSelection()
    }

    @objc fileprivate func customFieldChanged() {
        if let value = validCustomValue {
            customValue = value
        }
        updateSelection()
    }

    fileprivate var validCustomValue: Int? {
        guard let value = Int(customField.text ?? ""), (1...IncrementVC.maximumIncrement).contains(value) else { return nil }
        return value
    }

    fileprivate func getIncrement() -> Int? {
        if let index = selectedPresetIndex {
            return IncrementVC.presets[index]
        }
        return validCustomValue
    }

    fileprivate func updateSelection() {
        for (index, tile) in presetTiles.enumerated() {
            tile.isChosen = index == selectedPresetIndex
        }
        let isCustom = selectedPresetIndex == nil
        customTile.isChosen = isCustom

        if (isCustom && customField.text?.isEmpty != false) {
            customField.text = "\(customValue)"
        }
        customCard.isHidden = !isCustom
        customMinus.isEnabled = (validCustomValue ?? customValue) > 1
        customPlus.isEnabled = (validCustomValue ?? customValue) < IncrementVC.maximumIncrement

        if let increment = getIncrement() {
            previewLabel.text = increment == 1 ? "Each tap on + adds 1 encounter" : "Each tap on + adds \(increment) encounters"
            previewLabel.textColor = Color.accent
        }
        else {
            previewLabel.text = "Enter a number from 1 to \(IncrementVC.maximumIncrement)"
            previewLabel.textColor = Color.danger
        }
        saveButton.isEnabled = getIncrement() != nil
    }

    // MARK: Actions

    @objc fileprivate func cancelPressed() {
        dismissSheet()
    }

    @objc fileprivate func confirmPressed() {
        guard let increment = getIncrement() else { return }
        container.setIncrement.handle(SetIncrementCommand(number: number, increment: increment))
        Haptics.playSuccess()
        dismissSheet { [onSave] in
            onSave()
        }
    }
}

fileprivate class IncrementTile: UIControl {
    fileprivate let valueLabel = UILabel(style: .largeTitle, weight: .bold, color: Color.textPrimary)
    fileprivate let captionLabel = UILabel(style: .footnote, weight: .medium, color: Color.textTertiary)

    var isChosen = false {
        didSet {
            layer.borderWidth = isChosen ? 2 : 0
            backgroundColor = isChosen ? Color.accentSubtle : Color.surface
            valueLabel.textColor = isChosen ? Color.accent : Color.textPrimary
            captionLabel.textColor = isChosen ? Color.Orange400 : Color.textTertiary
            accessibilityTraits = isChosen ? [.button, .selected] : .button
        }
    }

    init(valueText: String, label: String, isWide: Bool) {
        super.init(frame: .zero)
        backgroundColor = Color.surface
        layer.cornerRadius = CornerRadius.standard
        layer.borderColor = Color.accent.cgColor
        valueLabel.font = UIFont.make(isWide ? .title2 : .largeTitle, weight: .bold, monospacedDigits: true)
        valueLabel.textAlignment = .center
        captionLabel.textAlignment = .center
        captionLabel.adjustsFontSizeToFitWidth = true
        captionLabel.minimumScaleFactor = 0.8
        captionLabel.text = label
        valueLabel.text = valueText

        let stack: UIStackView
        if (isWide) {
            let icon = UIImageView(image: UIImage.makeSymbol("slider.horizontal.3", pointSize: 17, weight: .semibold))
            icon.tintColor = Color.textTertiary
            captionLabel.font = UIFont.make(.body, weight: .semibold)
            stack = UIStackView(arrangedSubviews: [icon, captionLabel, UIView(), valueLabel])
            stack.spacing = 10
            stack.alignment = .center
            heightAnchor.constraint(equalToConstant: 56).isActive = true
        }
        else {
            stack = UIStackView(arrangedSubviews: [valueLabel, captionLabel])
            stack.axis = .vertical
            stack.spacing = 0
            heightAnchor.constraint(equalToConstant: 86).isActive = true
        }
        stack.isUserInteractionEnabled = false
        addAutoLayoutSubviews(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        isAccessibilityElement = true
        accessibilityTraits = .button
        accessibilityLabel = valueText.isEmpty ? label : "\(valueText), \(label)"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isHighlighted: Bool {
        didSet {
            alpha = isHighlighted ? 0.7 : 1
        }
    }
}
