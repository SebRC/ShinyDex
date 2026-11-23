import UIKit

class CatchRateControlCell: UITableViewCell {
    let titleLabel = UILabel(style: .body)
    let subtitleLabel = UILabel(style: .footnote, color: Color.textTertiary)

    init() {
        super.init(style: .default, reuseIdentifier: nil)
        backgroundColor = Color.surface
        selectionStyle = .none
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func layOut(_ arrangedSubviews: [UIView], axis: NSLayoutConstraint.Axis = .horizontal, subtitle: String? = nil) {
        titleLabel.numberOfLines = 0
        subtitleLabel.text = subtitle
        subtitleLabel.isHidden = subtitle == nil
        let titles = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        titles.axis = .vertical
        titles.spacing = 1
        titles.setContentHuggingPriority(.defaultLow, for: .horizontal)
        titles.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        for view in arrangedSubviews where axis == .horizontal {
            view.setContentHuggingPriority(.required, for: .horizontal)
            view.setContentCompressionResistancePriority(.required, for: .horizontal)
        }
        let stack = UIStackView(arrangedSubviews: [titles] + arrangedSubviews)
        stack.axis = axis
        stack.alignment = axis == .horizontal ? .center : .fill
        stack.spacing = axis == .horizontal ? Spacing.small : Spacing.medium
        contentView.addAutoLayoutSubviews(stack)
        stack.pinEdges(to: contentView, insets: UIEdgeInsets(top: Spacing.medium, left: Spacing.large, bottom: Spacing.medium, right: Spacing.large))
    }
}

final class CatchRateSwitchCell: CatchRateControlCell {
    let toggle = UISwitch()
    var onChange: ((Bool) -> Void)?

    init(title: String, subtitle: String? = nil) {
        super.init()
        titleLabel.text = title
        toggle.onTintColor = Color.accent
        toggle.addTarget(self, action: #selector(toggled), for: .valueChanged)
        toggle.accessibilityLabel = [title, subtitle].compactMap { $0 }.joined(separator: ", ")
        layOut([toggle], subtitle: subtitle)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc fileprivate func toggled() {
        onChange?(toggle.isOn)
    }
}

final class CatchRateStepperCell: CatchRateControlCell {
    fileprivate static let buttonDiameter: CGFloat = 34
    fileprivate static let firstRepeatDelay: TimeInterval = 0.4
    fileprivate static let repeatInterval: TimeInterval = 0.08

    let valueButton = UIButton(type: .system)
    let range: ClosedRange<Int>
    fileprivate let lowerButton = UIButton.makeRoundButton(.secondary, symbolName: "minus", diameter: CatchRateStepperCell.buttonDiameter, symbolSize: 14)
    fileprivate let raiseButton = UIButton.makeRoundButton(.secondary, symbolName: "plus", diameter: CatchRateStepperCell.buttonDiameter, symbolSize: 14)
    fileprivate let title: String
    fileprivate var repeatTimer: Timer?
    var onChange: ((Int) -> Void)?
    var onValueTapped: (() -> Void)?
    fileprivate(set) var value = 0

    init(title: String, subtitle: String? = nil, range: ClosedRange<Int>) {
        self.title = title
        self.range = range
        super.init()
        titleLabel.text = title
        var configuration = UIButton.Configuration.filled()
        configuration.baseBackgroundColor = Color.surfaceRaised
        configuration.baseForegroundColor = Color.textPrimary
        configuration.cornerStyle = .capsule
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)
        valueButton.configuration = configuration
        valueButton.accessibilityHint = "Type a value from \(range.lowerBound) to \(range.upperBound)."
        valueButton.addTarget(self, action: #selector(valueTapped), for: .touchUpInside)
        lowerButton.accessibilityLabel = "Lower \(title.lowercased())"
        raiseButton.accessibilityLabel = "Raise \(title.lowercased())"
        for (button, step) in [(lowerButton, -1), (raiseButton, 1)] {
            button.tag = step
            button.addTarget(self, action: #selector(stepPressed(_:)), for: .touchDown)
            button.addTarget(self, action: #selector(stepReleased), for: [.touchUpInside, .touchUpOutside, .touchCancel])
            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: CatchRateStepperCell.buttonDiameter),
                button.heightAnchor.constraint(equalToConstant: CatchRateStepperCell.buttonDiameter)
            ])
        }
        layOut([valueButton, lowerButton, raiseButton], subtitle: subtitle)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(value: Int) {
        self.value = value
        valueButton.configuration?.attributedTitle = AttributedString("\(value)", attributes: AttributeContainer([.font: UIFont.make(.body, weight: .semibold, monospacedDigits: true)]))
        valueButton.accessibilityLabel = "\(title), \(value)"
        lowerButton.isEnabled = value > range.lowerBound
        raiseButton.isEnabled = value < range.upperBound
        lowerButton.alpha = lowerButton.isEnabled ? 1 : 0.4
        raiseButton.alpha = raiseButton.isEnabled ? 1 : 0.4
    }

    @objc fileprivate func stepPressed(_ sender: UIButton) {
        let step = sender.tag
        applyStep(step)
        repeatTimer?.invalidate()
        repeatTimer = Timer.scheduledTimer(withTimeInterval: CatchRateStepperCell.firstRepeatDelay, repeats: false) { [weak self] _ in
            self?.repeatTimer = Timer.scheduledTimer(withTimeInterval: CatchRateStepperCell.repeatInterval, repeats: true) { _ in
                self?.applyStep(step)
            }
        }
    }

    @objc fileprivate func stepReleased() {
        repeatTimer?.invalidate()
        repeatTimer = nil
    }

    fileprivate func applyStep(_ step: Int) {
        let next = min(max(value + step, range.lowerBound), range.upperBound)
        guard next != value else {
            stepReleased()
            return
        }
        onChange?(next)
    }

    @objc fileprivate func valueTapped() {
        onValueTapped?()
    }
}

final class CatchRateHPCell: CatchRateControlCell {
    static let presets: [(title: String, percent: Int?)] = [("Full", 100), ("½", 50), ("Red", 15), ("1 HP", nil)]
    fileprivate static let yellowThreshold = 50
    fileprivate static let redThreshold = 20

    let slider = UISlider()
    let valueLabel = UILabel(style: .body, weight: .semibold)
    fileprivate var presetButtons = [UIButton]()
    var onPercentChange: ((Int) -> Void)?
    var onPresetPicked: ((Int?) -> Void)?

    override init() {
        super.init()
        titleLabel.text = "HP"
        valueLabel.font = UIFont.make(.body, weight: .semibold, monospacedDigits: true)
        valueLabel.textAlignment = .right
        slider.minimumValue = Float(CatchSituation.hpPercentRange.lowerBound)
        slider.maximumValue = Float(CatchSituation.hpPercentRange.upperBound)
        slider.maximumTrackTintColor = Color.surfaceRaised
        slider.accessibilityLabel = "HP"
        slider.addTarget(self, action: #selector(slid), for: .valueChanged)
        let presets = UIStackView()
        presets.distribution = .fillEqually
        presets.spacing = Spacing.small
        for (index, preset) in CatchRateHPCell.presets.enumerated() {
            let button = UIButton(type: .system)
            var configuration = UIButton.Configuration.filled()
            configuration.cornerStyle = .capsule
            configuration.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 8, bottom: 6, trailing: 8)
            button.configuration = configuration
            button.tag = index
            button.addTarget(self, action: #selector(presetPressed(_:)), for: .touchUpInside)
            presetButtons.append(button)
            presets.addArrangedSubview(button)
            setTitle(preset.title, of: button, isSelected: false)
        }
        layOut([valueLabel])
        guard let row = contentView.subviews.first as? UIStackView else { return }
        row.removeFromSuperview()
        let stack = UIStackView(arrangedSubviews: [row, slider, presets])
        stack.axis = .vertical
        stack.spacing = Spacing.medium
        contentView.addAutoLayoutSubviews(stack)
        stack.pinEdges(to: contentView, insets: UIEdgeInsets(top: Spacing.medium, left: Spacing.large, bottom: Spacing.medium, right: Spacing.large))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(percent: Int, isAtOneHP: Bool, currentHP: Int?, maxHP: Int?) {
        slider.value = Float(isAtOneHP ? CatchSituation.hpPercentRange.lowerBound : percent)
        let shownPercent = isAtOneHP ? 1 : percent
        let color = shownPercent > CatchRateHPCell.yellowThreshold ? Color.success : (shownPercent > CatchRateHPCell.redThreshold ? Color.accent : Color.danger)
        slider.minimumTrackTintColor = color
        if let currentHP = currentHP, let maxHP = maxHP {
            valueLabel.text = isAtOneHP ? "1/\(maxHP) HP" : "\(percent)% · \(currentHP)/\(maxHP)"
        }
        else {
            valueLabel.text = isAtOneHP ? "1 HP" : "\(percent)%"
        }
        slider.accessibilityValue = valueLabel.text
        for (button, preset) in zip(presetButtons, CatchRateHPCell.presets) {
            let isSelected = preset.percent.map { !isAtOneHP && $0 == percent } ?? isAtOneHP
            setTitle(preset.title, of: button, isSelected: isSelected)
        }
    }

    fileprivate func setTitle(_ title: String, of button: UIButton, isSelected: Bool) {
        button.configuration?.baseBackgroundColor = isSelected ? Color.accent : Color.surfaceRaised
        button.configuration?.baseForegroundColor = isSelected ? Color.onAccent : Color.textSecondary
        button.configuration?.attributedTitle = AttributedString(title, attributes: AttributeContainer([.font: UIFont.make(.footnote, weight: .semibold)]))
        button.accessibilityTraits = isSelected ? [.button, .selected] : .button
        button.accessibilityLabel = title == "½" ? "Half HP" : (title == "Red" ? "Red HP" : title)
    }

    @objc fileprivate func slid() {
        onPercentChange?(Int(slider.value.rounded()))
    }

    @objc fileprivate func presetPressed(_ sender: UIButton) {
        onPresetPicked?(CatchRateHPCell.presets[sender.tag].percent)
    }
}

final class CatchRateSegmentCell: CatchRateControlCell {
    let control: UISegmentedControl
    var onChange: ((Int) -> Void)?

    init(title: String, subtitle: String? = nil, items: [Any]) {
        control = UISegmentedControl(items: items)
        super.init()
        titleLabel.text = title
        control.selectedSegmentTintColor = Color.accent
        control.backgroundColor = Color.surfaceRaised
        control.setTitleTextAttributes([.foregroundColor: Color.textSecondary, .font: UIFont.make(.footnote, weight: .semibold)], for: .normal)
        control.setTitleTextAttributes([.foregroundColor: Color.onAccent, .font: UIFont.make(.footnote, weight: .bold)], for: .selected)
        control.accessibilityLabel = title
        control.addTarget(self, action: #selector(changed), for: .valueChanged)
        layOut([control], axis: .vertical, subtitle: subtitle)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc fileprivate func changed() {
        onChange?(control.selectedSegmentIndex)
    }
}

final class CatchRateSummaryCell: UITableViewCell {
    let label = UILabel(style: .subheadline, color: Color.textSecondary, lines: 0)

    init() {
        super.init(style: .default, reuseIdentifier: nil)
        backgroundColor = Color.surface
        let selectedBackground = UIView()
        selectedBackground.backgroundColor = Color.surfaceRaised
        selectedBackgroundView = selectedBackground
        accessoryType = .disclosureIndicator
        accessibilityHint = "Shows the conditions so you can change them."
        contentView.addAutoLayoutSubviews(label)
        label.pinEdges(to: contentView, insets: UIEdgeInsets(top: Spacing.medium, left: Spacing.large, bottom: Spacing.medium, right: Spacing.small))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class CatchRateHeaderView: UITableViewHeaderFooterView {
    static let reuseIdentifier = "catchRateHeader"

    fileprivate let label = SectionHeaderLabel(horizontalInset: 0)
    fileprivate let actionButton = UIButton(type: .system)
    fileprivate var action: (() -> Void)?

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        actionButton.titleLabel?.font = UIFont.make(.footnote, weight: .semibold)
        actionButton.tintColor = Color.accent
        actionButton.addTarget(self, action: #selector(actionPressed), for: .touchUpInside)
        actionButton.setContentHuggingPriority(.required, for: .horizontal)
        let row = UIStackView(arrangedSubviews: [label, actionButton])
        row.alignment = .lastBaseline
        contentView.addAutoLayoutSubviews(row)
        let margins = contentView.layoutMarginsGuide
        NSLayoutConstraint.activate([
            row.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            row.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            row.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Spacing.large),
            row.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(title: String, actionTitle: String?, symbolName: String? = nil, actionLabel: String? = nil, action: (() -> Void)?) {
        label.text = title
        actionButton.setTitle(actionTitle, for: .normal)
        actionButton.setImage(symbolName.flatMap { UIImage.makeSymbol($0, pointSize: 15, weight: .semibold) }, for: .normal)
        actionButton.accessibilityLabel = actionLabel ?? actionTitle
        actionButton.isHidden = action == nil
        self.action = action
    }

    @objc fileprivate func actionPressed() {
        action?()
    }
}

final class CatchRateResultView: UIView {
    fileprivate let ballImageView = UIImageView()
    fileprivate let captionLabel = UILabel(style: .caption1, weight: .semibold, color: Color.textTertiary)
    fileprivate let ballLabel = UILabel(style: .title3, weight: .bold)
    fileprivate let detailLabel = UILabel(style: .footnote, color: Color.textSecondary, lines: 2)
    fileprivate let chanceLabel = UILabel(style: .largeTitle, weight: .bold, color: Color.accent)

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Color.surface
        layer.cornerRadius = CornerRadius.standard
        ballImageView.contentMode = .scaleAspectFit
        ballImageView.layer.magnificationFilter = .nearest
        captionLabel.text = "BEST BALL"
        chanceLabel.font = UIFont.make(.largeTitle, weight: .bold, monospacedDigits: true)
        chanceLabel.adjustsFontSizeToFitWidth = true
        chanceLabel.minimumScaleFactor = 0.6
        chanceLabel.setContentHuggingPriority(.required, for: .horizontal)
        chanceLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        let texts = UIStackView(arrangedSubviews: [captionLabel, ballLabel, detailLabel])
        texts.axis = .vertical
        texts.spacing = 1
        let row = UIStackView(arrangedSubviews: [ballImageView, texts, chanceLabel])
        row.alignment = .center
        row.spacing = Spacing.medium
        addAutoLayoutSubviews(row)
        row.pinEdges(to: self, insets: UIEdgeInsets(top: Spacing.medium, left: Spacing.large, bottom: Spacing.medium, right: Spacing.large))
        NSLayoutConstraint.activate([
            ballImageView.widthAnchor.constraint(equalToConstant: 44),
            ballImageView.heightAnchor.constraint(equalToConstant: 44)
        ])
        isAccessibilityElement = true
        accessibilityTraits = .updatesFrequently
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(best: BallCatchRate) {
        ballImageView.image = UIImage(named: best.ball)
        ballLabel.text = best.ballName
        detailLabel.text = best.expectedThrowsText
        chanceLabel.text = best.formattedChance
        accessibilityLabel = "Best ball, \(best.ballName), \(best.formattedChance) per throw, \(best.expectedThrowsText)"
    }
}

final class BallRateCell: UITableViewCell {
    static let reuseIdentifier = "ballRateCell"
    fileprivate static let maximumBallImages = 4

    fileprivate let ballImages = UIStackView()
    fileprivate let nameLabel = UILabel(style: .body, weight: .semibold, lines: 0)
    fileprivate let detailLabel = UILabel(style: .footnote, color: Color.textSecondary, lines: 0)
    fileprivate let throwsLabel = UILabel(style: .footnote, color: Color.textTertiary, lines: 0)
    fileprivate let chanceLabel = UILabel(style: .body, weight: .bold)
    fileprivate let chanceBar = UIProgressView(progressViewStyle: .default)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = Color.surface
        let selectedBackground = UIView()
        selectedBackground.backgroundColor = Color.surfaceRaised
        selectedBackgroundView = selectedBackground
        ballImages.spacing = -14
        ballImages.alignment = .center
        chanceLabel.font = UIFont.make(.body, weight: .bold, monospacedDigits: true)
        chanceLabel.textAlignment = .right
        chanceLabel.setContentHuggingPriority(.required, for: .horizontal)
        chanceLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        chanceBar.trackTintColor = Color.surfaceRaised
        chanceBar.layer.cornerRadius = CornerRadius.tiny
        chanceBar.clipsToBounds = true
        let titleRow = UIStackView(arrangedSubviews: [nameLabel, chanceLabel])
        titleRow.alignment = .firstBaseline
        titleRow.spacing = Spacing.small
        let texts = UIStackView(arrangedSubviews: [titleRow, detailLabel, chanceBar, throwsLabel])
        texts.axis = .vertical
        texts.spacing = 3
        texts.setCustomSpacing(Spacing.small, after: detailLabel)
        texts.setCustomSpacing(Spacing.small, after: chanceBar)
        let row = UIStackView(arrangedSubviews: [ballImages, texts])
        row.alignment = .center
        row.spacing = Spacing.medium
        contentView.addAutoLayoutSubviews(row)
        row.pinEdges(to: contentView, insets: UIEdgeInsets(top: Spacing.medium, left: Spacing.large, bottom: Spacing.medium, right: Spacing.large))
        NSLayoutConstraint.activate([
            chanceBar.heightAnchor.constraint(equalToConstant: 4),
            ballImages.widthAnchor.constraint(greaterThanOrEqualToConstant: 32)
        ])
        isAccessibilityElement = true
        accessibilityTraits = .button
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(rates: [BallCatchRate], isBest: Bool, isExpanded: Bool) {
        guard let rate = rates.first else { return }
        ballImages.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for shownRate in rates.prefix(BallRateCell.maximumBallImages) {
            let imageView = UIImageView(image: UIImage(named: shownRate.ball))
            imageView.contentMode = .scaleAspectFit
            imageView.layer.magnificationFilter = .nearest
            NSLayoutConstraint.activate([imageView.widthAnchor.constraint(equalToConstant: 32), imageView.heightAnchor.constraint(equalToConstant: 32)])
            ballImages.addArrangedSubview(imageView)
        }
        let isGroup = rates.count > 1
        nameLabel.text = isGroup ? "\(rates.count) other balls" : rate.ballName
        detailLabel.text = isGroup ? BallRateCell.describeGroup(rates, isExpanded: isExpanded) : (rate.bonus.alwaysCatches ? rate.expectedThrowsText : (rate.bonusSummary ?? "No bonus right now"))
        chanceLabel.text = rate.formattedChance
        chanceLabel.textColor = isBest ? Color.accent : Color.textPrimary
        chanceBar.progress = Float(rate.chance)
        chanceBar.progressTintColor = isBest ? Color.accent : Color.textTertiary
        throwsLabel.text = rate.throwsSummary
        throwsLabel.isHidden = !isExpanded
        let names = isGroup ? rates.map { $0.ballName }.joined(separator: ", ") : rate.ballName
        accessibilityLabel = [names, isBest ? "best ball" : nil, "\(rate.formattedChance) per throw", detailLabel.text, isExpanded ? rate.throwsSummary : nil].compactMap { $0 }.joined(separator: ", ")
        accessibilityHint = isExpanded ? "Hides the throw details." : "Shows how many throws it takes."
    }

    fileprivate static let namesShownInGroup = 3

    fileprivate static func describeGroup(_ rates: [BallCatchRate], isExpanded: Bool) -> String {
        let names = rates.map { BallGrid.getDisplayName(of: $0.ball) }
        guard !isExpanded, names.count > namesShownInGroup else { return "No bonus · \(names.joined(separator: ", "))" }
        return "No bonus · \(names.prefix(namesShownInGroup).joined(separator: ", ")) and \(names.count - namesShownInGroup) more"
    }
}
