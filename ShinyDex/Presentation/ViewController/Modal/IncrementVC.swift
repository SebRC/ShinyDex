import UIKit

class IncrementVC: UIViewController, UITextFieldDelegate {
    fileprivate struct Preset {
        let value: Int
        let label: String
        let description: String
    }

    fileprivate static let maximumIncrement = 100
    fileprivate static let presets = [
        Preset(value: 1, label: "Single", description: "Single encounters, like soft resetting for one Pokémon, Pokéradar chaining or chain fishing."),
        Preset(value: 2, label: "Double", description: "Double hunting, like soft resetting for static encounters on two systems."),
        Preset(value: 3, label: "Radar ×3", description: "Pokéradar chaining when space is limited and three patches of grass shake most often."),
        Preset(value: 4, label: "Radar ×4", description: "Pokéradar chaining with plenty of space, where four patches of grass shake most often."),
        Preset(value: 5, label: "Radar ×5", description: "Generation 6 (X & Y) Pokéradar chaining, where five patches can shake at once, or receiving 5 gift Pokémon per reset."),
        Preset(value: 6, label: "Horde", description: "Horde encounters, where six Pokémon appear at once.")
    ]

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
    fileprivate let descriptionLabel = UILabel(fontSize: 15, color: Color.Grey300, lines: 0)
    fileprivate let previewLabel = UILabel(fontSize: 15, weight: .semibold, color: Color.Orange500, lines: 0)

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
        view.backgroundColor = Color.Grey900
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelPressed))
        saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(confirmPressed))
        navigationItem.rightBarButtonItem = saveButton

        if let index = IncrementVC.presets.firstIndex(where: { $0.value == currentIncrement }) {
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
            let tile = IncrementTile(valueText: "\(preset.value)", label: preset.label, isWide: false)
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

        let descriptionCard = UIView()
        descriptionCard.backgroundColor = Color.Grey800
        descriptionCard.layer.cornerRadius = CornerRadius.standard
        let infoIcon = UIImageView(image: UIImage.makeSymbol("info.circle", pointSize: 15, weight: .semibold))
        infoIcon.tintColor = Color.Grey400
        infoIcon.setContentHuggingPriority(.required, for: .horizontal)
        let descriptionRow = UIStackView(arrangedSubviews: [infoIcon, descriptionLabel])
        descriptionRow.spacing = 10
        descriptionRow.alignment = .top
        descriptionCard.addAutoLayoutSubviews(descriptionRow)
        descriptionRow.pinEdges(to: descriptionCard, insets: UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14))
        stack.setCustomSpacing(18, after: customCard)
        stack.addArrangedSubview(descriptionCard)

        previewLabel.textAlignment = .center
        stack.setCustomSpacing(16, after: descriptionCard)
        stack.addArrangedSubview(previewLabel)

        view.addAutoLayoutSubviews(scrollView)
        scrollView.pinEdges(to: view)
        scrollView.addAutoLayoutSubviews(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),
            stack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16)
        ])
    }

    fileprivate func setUpCustomCard() {
        customCard.backgroundColor = Color.Grey800
        customCard.layer.cornerRadius = CornerRadius.standard
        for (button, symbol, label) in [(customMinus, "minus", "Decrease"), (customPlus, "plus", "Increase")] {
            button.setImage(UIImage.makeSymbol(symbol, pointSize: 20, weight: .bold), for: .normal)
            button.tintColor = Color.Grey200
            button.backgroundColor = Color.Grey700
            button.layer.cornerRadius = 22
            button.accessibilityLabel = label
            button.widthAnchor.constraint(equalToConstant: 56).isActive = true
            button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        }
        customMinus.addTarget(self, action: #selector(customMinusPressed), for: .touchUpInside)
        customPlus.addTarget(self, action: #selector(customPlusPressed), for: .touchUpInside)

        customField.delegate = self
        customField.keyboardType = .numberPad
        customField.textAlignment = .center
        customField.font = UIFont.monospacedDigitSystemFont(ofSize: 30, weight: .bold)
        customField.textColor = Color.Grey100
        customField.accessibilityLabel = "Custom encounters per tap"
        customField.addTarget(self, action: #selector(customFieldChanged), for: .editingChanged)

        let rangeLabel = UILabel(fontSize: 12, color: Color.Grey500)
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
            return IncrementVC.presets[index].value
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

        descriptionLabel.text = selectedPresetIndex.map { IncrementVC.presets[$0].description }
            ?? "Set your own number of encounters per tap, from 1 to \(IncrementVC.maximumIncrement)."
        if let increment = getIncrement() {
            previewLabel.text = increment == 1 ? "Each tap on + adds 1 encounter" : "Each tap on + adds \(increment) encounters"
            previewLabel.textColor = Color.Orange500
        }
        else {
            previewLabel.text = "Enter a number from 1 to \(IncrementVC.maximumIncrement)"
            previewLabel.textColor = Color.Danger400
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
    fileprivate let valueLabel = UILabel(fontSize: 34, weight: .bold, color: Color.Grey100)
    fileprivate let captionLabel = UILabel(fontSize: 13, weight: .medium, color: Color.Grey400)

    var isChosen = false {
        didSet {
            layer.borderWidth = isChosen ? 2 : 0
            backgroundColor = isChosen ? Color.Orange900 : Color.Grey800
            valueLabel.textColor = isChosen ? Color.Orange500 : Color.Grey100
            captionLabel.textColor = isChosen ? Color.Orange400 : Color.Grey400
            accessibilityTraits = isChosen ? [.button, .selected] : .button
        }
    }

    init(valueText: String, label: String, isWide: Bool) {
        super.init(frame: .zero)
        backgroundColor = Color.Grey800
        layer.cornerRadius = 14
        layer.borderColor = Color.Orange500.cgColor
        valueLabel.font = UIFont.monospacedDigitSystemFont(ofSize: isWide ? 22 : 34, weight: .bold)
        valueLabel.textAlignment = .center
        captionLabel.textAlignment = .center
        captionLabel.adjustsFontSizeToFitWidth = true
        captionLabel.minimumScaleFactor = 0.8
        captionLabel.text = label
        valueLabel.text = valueText

        let stack: UIStackView
        if (isWide) {
            let icon = UIImageView(image: UIImage.makeSymbol("slider.horizontal.3", pointSize: 17, weight: .semibold))
            icon.tintColor = Color.Grey400
            captionLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
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
