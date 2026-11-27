import UIKit

class CatchStatsVC: UIViewController {
    fileprivate enum Mode: Int, CaseIterable {
        case ivs
        case evs

        var title: String {
            switch self {
            case .ivs: return "IVs"
            case .evs: return "EVs"
            }
        }

        var footnote: String {
            switch self {
            case .ivs: return "Each stat has an IV from 0 to 31. Tap a number to type an exact value, or leave it empty if you don't know it."
            case .evs: return "Each stat counts up to 252 EVs and holds up to 255, so the last 3 are wasted. A Pokémon can have up to 510 in total. Tap a number to type an exact value."
            }
        }
    }

    fileprivate static let evSteps = [1, 2, 3, 4, 8, 10]
    fileprivate static let roundButtonSize: CGFloat = 36
    fileprivate static let disabledAlpha: CGFloat = 0.4

    fileprivate let container: AppContainer
    fileprivate let catchId: CatchID
    fileprivate let spriteImage: UIImage?
    fileprivate var stats: CatchStatSheet?
    fileprivate var level = GetCatchStatsHandler.defaultLevel
    fileprivate var mode = Mode.ivs

    fileprivate let levelButton = UIButton(type: .system)
    fileprivate let lowerLevelButton = UIButton.makeRoundButton(.secondary, symbolName: "minus", diameter: CatchStatsVC.roundButtonSize, symbolSize: 15)
    fileprivate let raiseLevelButton = UIButton.makeRoundButton(.secondary, symbolName: "plus", diameter: CatchStatsVC.roundButtonSize, symbolSize: 15)
    fileprivate let natureButton = UIButton(type: .system)
    fileprivate let hiddenPowerLabel = UILabel(style: .subheadline, weight: .semibold)
    fileprivate let statColumns = UIStackView()
    fileprivate let modeControl = UISegmentedControl(items: Mode.allCases.map { $0.title })
    fileprivate let summaryCaptionLabel = UILabel(style: .caption1, weight: .semibold, color: Color.textTertiary)
    fileprivate let summaryValueLabel = UILabel(style: .title2, weight: .bold)
    fileprivate let summaryDetailLabel = UILabel(style: .footnote, color: Color.textTertiary)
    fileprivate let totalBar = UIProgressView(progressViewStyle: .default)
    fileprivate let stepSection = UIStackView()
    fileprivate let stepControl = UISegmentedControl(items: CatchStatsVC.evSteps.map { "+\($0)" })
    fileprivate let ivList = UIStackView()
    fileprivate let evList = UIStackView()
    fileprivate let footnoteLabel = UILabel(style: .caption1, color: Color.textQuaternary, lines: 0)
    fileprivate var ivRows = [IVStatRow]()
    fileprivate var evRows = [EVStatRow]()
    fileprivate var resetButton: UIBarButtonItem!

    init(container: AppContainer, caught: CatchSummary) {
        self.container = container
        catchId = caught.id
        spriteImage = caught.spriteImage
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Stats"
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = Color.background
        resetButton = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(resetPressed))
        navigationItem.rightBarButtonItem = resetButton

        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        let stack = UIStackView(arrangedSubviews: [makeStatsCard(), makeModeControl(), makeStepSection(), makeEditorCard(), footnoteLabel])
        stack.axis = .vertical
        stack.spacing = Spacing.large
        view.addAutoLayoutSubviews(scrollView)
        scrollView.pinEdges(to: view)
        scrollView.addAutoLayoutSubviews(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: Spacing.medium),
            stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -Spacing.extraLarge),
            stack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: Spacing.screenMargin),
            stack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -Spacing.screenMargin)
        ])
        refresh()
    }

    // MARK: Layout

    fileprivate func makeStatsCard() -> UIView {
        let card = UIView()
        card.backgroundColor = Color.surface
        card.layer.cornerRadius = CornerRadius.standard

        let sprite = UIImageView(image: spriteImage)
        sprite.contentMode = .scaleAspectFit
        sprite.layer.magnificationFilter = .nearest
        sprite.isAccessibilityElement = false
        let caption = UILabel(style: .caption1, weight: .semibold, color: Color.textTertiary)
        caption.text = "LEVEL"
        caption.isAccessibilityElement = false
        levelButton.titleLabel?.font = UIFont.make(.largeTitle, weight: .bold, monospacedDigits: true)
        levelButton.titleLabel?.adjustsFontForContentSizeCategory = true
        levelButton.setTitleColor(Color.textPrimary, for: .normal)
        levelButton.contentHorizontalAlignment = .leading
        levelButton.accessibilityHint = "Type a level from \(StatCalculator.levelRange.lowerBound) to \(StatCalculator.levelRange.upperBound)."
        levelButton.addTarget(self, action: #selector(levelPressed), for: .touchUpInside)
        lowerLevelButton.accessibilityLabel = "Lower level"
        lowerLevelButton.addTarget(self, action: #selector(lowerLevelPressed), for: .touchUpInside)
        raiseLevelButton.accessibilityLabel = "Raise level"
        raiseLevelButton.addTarget(self, action: #selector(raiseLevelPressed), for: .touchUpInside)

        let levelLabels = UIStackView(arrangedSubviews: [caption, levelButton])
        levelLabels.axis = .vertical
        levelLabels.alignment = .leading
        let levelRow = UIStackView(arrangedSubviews: [sprite, levelLabels, UIView(), lowerLevelButton, raiseLevelButton])
        levelRow.alignment = .center
        levelRow.spacing = Spacing.small
        levelRow.setCustomSpacing(Spacing.medium, after: sprite)

        var natureConfiguration = UIButton.Configuration.plain()
        natureConfiguration.image = UIImage.makeSymbol("chevron.right", pointSize: 12, weight: .semibold)
        natureConfiguration.imagePlacement = .trailing
        natureConfiguration.imagePadding = Spacing.extraSmall
        natureConfiguration.contentInsets = .zero
        natureConfiguration.baseForegroundColor = Color.textQuaternary
        natureButton.configuration = natureConfiguration
        natureButton.contentHorizontalAlignment = .leading
        natureButton.accessibilityHint = "Choose a nature."
        natureButton.addTarget(self, action: #selector(naturePressed), for: .touchUpInside)

        statColumns.distribution = .fillEqually
        statColumns.backgroundColor = Color.surfaceRaised
        statColumns.layer.cornerRadius = CornerRadius.small
        statColumns.isLayoutMarginsRelativeArrangement = true
        statColumns.directionalLayoutMargins = NSDirectionalEdgeInsets(top: Spacing.small, leading: Spacing.extraSmall, bottom: Spacing.small, trailing: Spacing.extraSmall)

        let content = UIStackView(arrangedSubviews: [levelRow, natureButton, hiddenPowerLabel, statColumns])
        content.setCustomSpacing(Spacing.extraSmall, after: natureButton)
        content.axis = .vertical
        content.spacing = Spacing.medium
        card.addAutoLayoutSubviews(content)
        content.pinEdges(to: card, insets: UIEdgeInsets(top: Spacing.medium, left: Spacing.medium, bottom: Spacing.medium, right: Spacing.medium))
        NSLayoutConstraint.activate([
            sprite.widthAnchor.constraint(equalToConstant: 64),
            sprite.heightAnchor.constraint(equalToConstant: 64)
        ])
        return card
    }

    fileprivate func makeModeControl() -> UIView {
        modeControl.selectedSegmentIndex = mode.rawValue
        modeControl.selectedSegmentTintColor = Color.accent
        modeControl.backgroundColor = Color.surface
        modeControl.setTitleTextAttributes([.foregroundColor: Color.onAccent, .font: UIFont.make(.subheadline, weight: .bold)], for: .selected)
        modeControl.setTitleTextAttributes([.foregroundColor: Color.textSecondary, .font: UIFont.make(.subheadline, weight: .medium)], for: .normal)
        modeControl.heightAnchor.constraint(greaterThanOrEqualToConstant: 34).isActive = true
        modeControl.accessibilityLabel = "Edit"
        modeControl.addTarget(self, action: #selector(modeChanged), for: .valueChanged)
        return modeControl
    }

    fileprivate func makeStepSection() -> UIView {
        let caption = UILabel(style: .footnote, weight: .semibold, color: Color.textTertiary)
        caption.text = "EACH TAP ADDS"
        stepControl.selectedSegmentIndex = 0
        stepControl.selectedSegmentTintColor = Color.accent
        stepControl.backgroundColor = Color.surface
        stepControl.setTitleTextAttributes([.foregroundColor: Color.onAccent, .font: UIFont.make(.subheadline, weight: .bold, monospacedDigits: true)], for: .selected)
        stepControl.setTitleTextAttributes([.foregroundColor: Color.textSecondary, .font: UIFont.make(.subheadline, weight: .medium, monospacedDigits: true)], for: .normal)
        stepControl.heightAnchor.constraint(greaterThanOrEqualToConstant: 34).isActive = true
        stepControl.accessibilityLabel = "EVs per tap"
        let hint = UILabel(style: .caption1, color: Color.textQuaternary, lines: 0)
        hint.text = "1–3 per knockout · 8 with a Power item · 10 per vitamin"
        [caption, stepControl, hint].forEach(stepSection.addArrangedSubview)
        stepSection.axis = .vertical
        stepSection.spacing = Spacing.extraSmall
        return stepSection
    }

    fileprivate func makeEditorCard() -> UIView {
        let card = UIView()
        card.backgroundColor = Color.surface
        card.layer.cornerRadius = CornerRadius.standard

        summaryValueLabel.font = UIFont.make(.title2, weight: .bold, monospacedDigits: true)
        summaryDetailLabel.font = UIFont.make(.footnote, monospacedDigits: true)
        totalBar.progressTintColor = Color.accent
        totalBar.trackTintColor = Color.surfaceRaised
        totalBar.layer.cornerRadius = CornerRadius.tiny
        totalBar.clipsToBounds = true
        totalBar.heightAnchor.constraint(equalToConstant: 6).isActive = true
        let summary = UIStackView(arrangedSubviews: [summaryCaptionLabel, summaryValueLabel, summaryDetailLabel, totalBar])
        summary.axis = .vertical
        summary.setCustomSpacing(Spacing.small, after: summaryDetailLabel)
        summary.isAccessibilityElement = true

        for stat in Stat.allCases {
            let ivRow = IVStatRow(stat: stat)
            ivRow.onChange = { [weak self] direction in self?.changeIV(of: stat, by: direction) }
            ivRow.onValueTapped = { [weak self] in self?.promptExactIV(for: stat) }
            ivRows.append(ivRow)
            ivList.addArrangedSubview(ivRow)
            let evRow = EVStatRow(stat: stat)
            evRow.onChange = { [weak self] direction in self?.changeEVs(of: stat, by: direction) }
            evRow.onValueTapped = { [weak self] in self?.promptExactEVs(for: stat) }
            evRows.append(evRow)
            evList.addArrangedSubview(evRow)
        }
        for list in [ivList, evList] {
            list.axis = .vertical
            list.spacing = 14
        }

        let content = UIStackView(arrangedSubviews: [summary, ivList, evList])
        content.axis = .vertical
        content.spacing = Spacing.large
        card.addAutoLayoutSubviews(content)
        content.pinEdges(to: card, insets: UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 10))
        return card
    }

    // MARK: Level

    fileprivate func changeLevel(to newLevel: Int) {
        let clamped = StatCalculator.clampLevel(newLevel)
        guard clamped != level else {
            Haptics.playWarning()
            return
        }
        Haptics.tap()
        save(.level(clamped))
    }

    @objc fileprivate func lowerLevelPressed() {
        changeLevel(to: level - 1)
    }

    @objc fileprivate func raiseLevelPressed() {
        changeLevel(to: level + 1)
    }

    @objc fileprivate func levelPressed() {
        let range = StatCalculator.levelRange
        presentTextInput(title: "Level",
                         message: "Enter its level, from \(range.lowerBound) to \(range.upperBound).",
                         text: "\(level)",
                         placeholder: "Level",
                         keyboardType: .numberPad,
                         isValid: { Int($0).map { range.contains($0) } ?? false }) { [weak self] value in
            guard let newLevel = Int(value) else { return }
            self?.save(.level(newLevel))
        }
    }

    // MARK: Nature

    @objc fileprivate func naturePressed() {
        let picker = NaturePickerVC(selected: stats?.nature) { [weak self] nature in
            self?.save(.nature(nature))
        }
        navigationController?.pushViewController(picker, animated: true)
    }

    // MARK: IVs

    fileprivate func changeIV(of stat: Stat, by direction: Int) {
        guard let ivs = stats?.ivs else { return }
        let target = ivs[stat].map { $0 + direction } ?? IndividualValues.range.lowerBound
        guard IndividualValues.range.contains(target) else {
            Haptics.playWarning()
            return
        }
        Haptics.tap()
        save(.ivs(ivs.setting(target, for: stat)))
    }

    fileprivate func promptExactIV(for stat: Stat) {
        guard let ivs = stats?.ivs else { return }
        let range = IndividualValues.range
        presentTextInput(title: stat.name,
                         message: "Enter a number from \(range.lowerBound) to \(range.upperBound), or leave it empty if you don't know it.",
                         text: ivs[stat].map(String.init),
                         placeholder: "Unknown",
                         keyboardType: .numberPad,
                         isValid: { $0.isEmpty || (Int($0).map { range.contains($0) } ?? false) }) { [weak self] value in
            self?.save(.ivs(ivs.setting(Int(value), for: stat)))
        }
    }

    // MARK: EVs

    fileprivate var evStep: Int {
        return CatchStatsVC.evSteps[stepControl.selectedSegmentIndex]
    }

    fileprivate func changeEVs(of stat: Stat, by direction: Int) {
        guard let evs = stats?.evs else { return }
        let updated = evs.adding(direction * evStep, to: stat)
        guard updated != evs else {
            Haptics.playWarning()
            return
        }
        Haptics.tap()
        save(.evs(updated))
    }

    fileprivate func promptExactEVs(for stat: Stat) {
        guard let evs = stats?.evs else { return }
        let ceiling = min(EffortValues.maximumPerStat, evs[stat] + evs.remaining)
        presentTextInput(title: stat.name,
                         message: "Enter a number from 0 to \(ceiling).",
                         text: "\(evs[stat])",
                         placeholder: "EVs",
                         keyboardType: .numberPad,
                         isValid: { Int($0).map { (0...ceiling).contains($0) } ?? false }) { [weak self] value in
            guard let number = Int(value) else { return }
            self?.save(.evs(evs.setting(number, for: stat)))
        }
    }

    // MARK: Saving

    fileprivate func save(_ change: UpdateCatchCommand.Change) {
        try? container.updateCatch.handle(UpdateCatchCommand(catchId: catchId, change: change))
        refresh()
        AchievementAnnouncer.announceNewUnlocks(using: container)
    }

    @objc fileprivate func modeChanged() {
        mode = Mode(rawValue: modeControl.selectedSegmentIndex) ?? .ivs
        Haptics.tap()
        refresh()
    }

    @objc fileprivate func resetPressed() {
        let pokemonName = stats?.pokemonName ?? "this Pokémon"
        switch mode {
        case .ivs:
            presentDestructiveConfirmation(title: "Reset IVs?", message: "All of \(pokemonName)'s IVs go back to unknown.", destructiveTitle: "Reset") { [weak self] in
                self?.save(.ivs(IndividualValues()))
            }
        case .evs:
            presentDestructiveConfirmation(title: "Reset EVs?", message: "All of \(pokemonName)'s EVs go back to 0.", destructiveTitle: "Reset") { [weak self] in
                self?.save(.evs(EffortValues()))
            }
        }
    }

    // MARK: Refresh

    fileprivate func refresh() {
        guard let stats = container.getCatchStats.handle(GetCatchStatsQuery(catchId: catchId)) else { return }
        self.stats = stats
        level = stats.level
        refreshLevel()
        refreshNature(stats.nature)
        refreshHiddenPower(stats.hiddenPower)
        refreshStatColumns(with: stats)
        stepSection.isHidden = mode != .evs
        ivList.isHidden = mode != .ivs
        evList.isHidden = mode != .evs
        totalBar.isHidden = mode != .evs
        footnoteLabel.text = mode.footnote
        switch mode {
        case .ivs: refreshIVs(stats.ivs)
        case .evs: refreshEVs(stats.evs)
        }
        summaryCaptionLabel.superview?.accessibilityLabel = [summaryCaptionLabel.text, summaryValueLabel.text, summaryDetailLabel.text].compactMap { $0 }.joined(separator: ", ")
    }

    fileprivate func refreshLevel() {
        levelButton.setTitle("\(level)", for: .normal)
        levelButton.accessibilityLabel = "Level \(level)"
        lowerLevelButton.isEnabled = level > StatCalculator.levelRange.lowerBound
        raiseLevelButton.isEnabled = level < StatCalculator.levelRange.upperBound
        lowerLevelButton.alpha = lowerLevelButton.isEnabled ? 1 : CatchStatsVC.disabledAlpha
        raiseLevelButton.alpha = raiseLevelButton.isEnabled ? 1 : CatchStatsVC.disabledAlpha
    }

    fileprivate func refreshHiddenPower(_ hiddenPower: HiddenPower?) {
        hiddenPowerLabel.isHidden = hiddenPower == nil
        guard let hiddenPower = hiddenPower else { return }
        let font = UIFont.make(.subheadline, weight: .semibold)
        let text = NSMutableAttributedString(string: "Hidden Power  ", attributes: [.font: font, .foregroundColor: Color.textTertiary])
        text.append(NSAttributedString(string: hiddenPower.type, attributes: [.font: font, .foregroundColor: MoveTypes.colors[hiddenPower.type] ?? Color.textPrimary]))
        text.append(NSAttributedString(string: " · \(hiddenPower.power) power", attributes: [.font: font, .foregroundColor: Color.textPrimary]))
        hiddenPowerLabel.attributedText = text
        hiddenPowerLabel.accessibilityLabel = "Hidden Power, \(hiddenPower.type), \(hiddenPower.power) power"
    }

    fileprivate func refreshNature(_ nature: Nature?) {
        let text = NSMutableAttributedString(string: "Nature  ", attributes: [.font: UIFont.make(.subheadline, weight: .semibold), .foregroundColor: Color.textTertiary])
        let value = nature.map { "\($0.name) · \($0.effectSummary)" } ?? "Unknown"
        text.append(NSAttributedString(string: value, attributes: [.font: UIFont.make(.subheadline, weight: .semibold), .foregroundColor: nature == nil ? Color.textTertiary : Color.textPrimary]))
        natureButton.configuration?.attributedTitle = AttributedString(text)
        natureButton.accessibilityLabel = "Nature, \(value)"
    }

    fileprivate func refreshStatColumns(with stats: CatchStatSheet) {
        statColumns.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for line in stats.lines {
            statColumns.addArrangedSubview(makeColumn(for: line, nature: stats.nature))
        }
    }

    fileprivate func makeColumn(for line: CatchStatLine, nature: Nature?) -> UIView {
        let nameLabel = UILabel(style: .caption2, weight: .semibold, color: Color.textTertiary)
        let name = NSMutableAttributedString(string: line.stat.shortName)
        switch line.stat {
        case nature?.raisedStat: name.append(NSAttributedString(string: "+", attributes: [.foregroundColor: Color.success]))
        case nature?.loweredStat: name.append(NSAttributedString(string: "−", attributes: [.foregroundColor: Color.danger]))
        default: break
        }
        nameLabel.attributedText = name
        let valueLabel = UILabel(style: .title3, weight: .bold)
        valueLabel.font = UIFont.make(.title3, weight: .bold, monospacedDigits: true)
        valueLabel.text = line.value.map(String.init) ?? "–"
        valueLabel.textColor = line.value == nil ? Color.textQuaternary : Color.textPrimary
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.7
        let baseLabel = UILabel(style: .caption2, color: Color.textQuaternary)
        baseLabel.font = UIFont.make(.caption2, monospacedDigits: true)
        baseLabel.text = line.base.map { "base \($0)" }
        let column = UIStackView(arrangedSubviews: [nameLabel, valueLabel, baseLabel])
        column.axis = .vertical
        column.alignment = .center
        column.spacing = 1
        column.isAccessibilityElement = true
        column.accessibilityLabel = "\(line.stat.name), " + (line.value.map { "\($0) at level \(level)" } ?? "unknown until its IV is logged") + (line.base.map { ", base \($0)" } ?? "")
        return column
    }

    fileprivate func refreshIVs(_ ivs: IndividualValues) {
        summaryCaptionLabel.text = "PERFECT IVS"
        summaryValueLabel.text = "\(ivs.perfectCount) / \(Stat.allCases.count)"
        summaryDetailLabel.attributedText = ivs.makeColoredSummary(unknownColor: Color.textTertiary)
        for row in ivRows {
            row.update(value: ivs[row.stat])
        }
        resetButton.isEnabled = !ivs.isEmpty
    }

    fileprivate func refreshEVs(_ evs: EffortValues) {
        summaryCaptionLabel.text = "TOTAL EVS"
        summaryValueLabel.text = "\(evs.total) / \(EffortValues.maximumTotal)"
        summaryDetailLabel.attributedText = nil
        summaryDetailLabel.text = evs.remaining == 0 ? "Fully trained" : "\(evs.remaining) left to assign"
        totalBar.progress = Float(evs.total) / Float(EffortValues.maximumTotal)
        for row in evRows {
            row.update(value: evs[row.stat], wasted: evs.countWasted(in: row.stat), canIncrease: evs[row.stat] < EffortValues.maximumPerStat && evs.remaining > 0)
        }
        resetButton.isEnabled = !evs.isEmpty
    }
}

fileprivate class StatEditorRow: UIView {
    let stat: Stat
    var onChange: ((Int) -> Void)?
    var onValueTapped: (() -> Void)?

    let valueButton = UIButton(type: .system)
    let bar = UIProgressView(progressViewStyle: .default)
    let minusButton = UIButton(type: .system)
    let plusButton = UIButton(type: .system)

    init(stat: Stat, lowerLabel: String, raiseLabel: String) {
        self.stat = stat
        super.init(frame: .zero)
        let nameLabel = UILabel(style: .subheadline, weight: .semibold)
        nameLabel.text = stat.name
        valueButton.titleLabel?.font = UIFont.make(.subheadline, weight: .bold, monospacedDigits: true)
        valueButton.setTitleColor(Color.textPrimary, for: .normal)
        valueButton.contentHorizontalAlignment = .right
        valueButton.accessibilityHint = "Type an exact value."
        valueButton.addTarget(self, action: #selector(valueTapped), for: .touchUpInside)
        bar.trackTintColor = Color.surfaceRaised
        bar.layer.cornerRadius = CornerRadius.tiny
        bar.clipsToBounds = true

        for (button, symbol, direction) in [(minusButton, "minus", -1), (plusButton, "plus", 1)] {
            button.setImage(UIImage.makeSymbol(symbol, pointSize: 15, weight: .bold), for: .normal)
            button.tintColor = Color.textPrimary
            button.backgroundColor = Color.surfaceRaised
            button.layer.cornerRadius = CornerRadius.capsule(height: 36)
            button.tag = direction
            button.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
            button.widthAnchor.constraint(equalToConstant: 36).isActive = true
            button.heightAnchor.constraint(equalToConstant: 36).isActive = true
        }
        minusButton.accessibilityLabel = lowerLabel
        plusButton.accessibilityLabel = raiseLabel

        let titleRow = UIStackView(arrangedSubviews: [nameLabel, valueButton])
        let labels = UIStackView(arrangedSubviews: [titleRow, bar])
        labels.axis = .vertical
        labels.spacing = 6
        let row = UIStackView(arrangedSubviews: [labels, minusButton, plusButton])
        row.alignment = .center
        row.spacing = 8
        row.setCustomSpacing(14, after: labels)
        addAutoLayoutSubviews(row)
        row.pinEdges(to: self)
        bar.heightAnchor.constraint(equalToConstant: 6).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateButtons(canDecrease: Bool, canIncrease: Bool) {
        minusButton.isEnabled = canDecrease
        plusButton.isEnabled = canIncrease
        minusButton.alpha = canDecrease ? 1 : 0.4
        plusButton.alpha = canIncrease ? 1 : 0.4
    }

    @objc fileprivate func buttonPressed(_ sender: UIButton) {
        onChange?(sender.tag)
    }

    @objc fileprivate func valueTapped() {
        onValueTapped?()
    }
}

fileprivate final class IVStatRow: StatEditorRow {
    init(stat: Stat) {
        super.init(stat: stat, lowerLabel: "Lower \(stat.name) IV", raiseLabel: "Raise \(stat.name) IV")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(value: Int?) {
        let maximum = IndividualValues.range.upperBound
        valueButton.setTitle(value.map { "\($0) / \(maximum)" } ?? "Unknown", for: .normal)
        valueButton.setTitleColor(value.map(IndividualValues.getColor(for:)) ?? Color.textTertiary, for: .normal)
        valueButton.accessibilityLabel = "\(stat.name), \(value.map { "\($0) IV" } ?? "unknown IV")"
        bar.progress = Float(value ?? 0) / Float(maximum)
        bar.progressTintColor = value.map(IndividualValues.getColor(for:))
        updateButtons(canDecrease: value.map { $0 > IndividualValues.range.lowerBound } ?? false, canIncrease: value.map { $0 < maximum } ?? true)
    }
}

fileprivate final class EVStatRow: StatEditorRow {
    init(stat: Stat) {
        super.init(stat: stat, lowerLabel: "Remove \(stat.name) EVs", raiseLabel: "Add \(stat.name) EVs")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(value: Int, wasted: Int, canIncrease: Bool) {
        valueButton.setTitle(wasted > 0 ? "\(value) · \(wasted) wasted" : "\(value) / \(EffortValues.maximumUsefulPerStat)", for: .normal)
        valueButton.setTitleColor(Color.textPrimary, for: .normal)
        valueButton.accessibilityLabel = "\(stat.name), \(value) EVs" + (wasted > 0 ? ", \(wasted) wasted" : "")
        bar.progress = Float(min(value, EffortValues.maximumUsefulPerStat)) / Float(EffortValues.maximumUsefulPerStat)
        bar.progressTintColor = value >= EffortValues.maximumUsefulPerStat ? Color.accent : Color.success
        updateButtons(canDecrease: value > 0, canIncrease: canIncrease)
    }
}
