import UIKit

class EVTrainingVC: UIViewController {
    fileprivate static let steps = [1, 2, 3, 4, 8, 10]

    fileprivate let container: AppContainer
    fileprivate let catchId: CatchID
    fileprivate var caught: CatchSummary
    fileprivate let totalLabel = UILabel(fontSize: 34, weight: .bold, color: Color.Grey100)
    fileprivate let remainingLabel = UILabel(fontSize: 13, color: Color.Grey400)
    fileprivate let totalBar = UIProgressView(progressViewStyle: .default)
    fileprivate let stepControl = UISegmentedControl(items: EVTrainingVC.steps.map { "+\($0)" })
    fileprivate var rows = [EVStatRow]()
    fileprivate var resetButton: UIBarButtonItem!

    init(container: AppContainer, caught: CatchSummary) {
        self.container = container
        catchId = caught.id
        self.caught = caught
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "EV training"
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = Color.Grey900
        resetButton = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(resetPressed))
        navigationItem.rightBarButtonItem = resetButton

        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        let stack = UIStackView(arrangedSubviews: [makeTotalCard(), makeStepSection(), makeStatsCard()])
        stack.axis = .vertical
        stack.spacing = 16
        let footnote = UILabel(fontSize: 12, color: Color.Grey500, lines: 0)
        footnote.text = "Each stat can have up to 252 EVs, and a Pokémon up to 510 in total. Tap a number to type an exact value."
        stack.addArrangedSubview(footnote)

        view.addAutoLayoutSubviews(scrollView)
        scrollView.pinEdges(to: view)
        scrollView.addAutoLayoutSubviews(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 12),
            stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),
            stack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16)
        ])
        refresh()
    }

    // MARK: Layout

    fileprivate func makeTotalCard() -> UIView {
        let card = UIView()
        card.backgroundColor = Color.Grey800
        card.layer.cornerRadius = 14
        let sprite = UIImageView(image: caught.spriteImage)
        sprite.contentMode = .scaleAspectFit
        sprite.layer.magnificationFilter = .nearest
        sprite.isAccessibilityElement = false
        let caption = UILabel(fontSize: 12, weight: .semibold, color: Color.Grey400)
        caption.text = "TOTAL EVS"
        totalLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 34, weight: .bold)
        totalBar.progressTintColor = Color.Orange500
        totalBar.trackTintColor = Color.Grey700
        totalBar.layer.cornerRadius = 3
        totalBar.clipsToBounds = true

        let labels = UIStackView(arrangedSubviews: [caption, totalLabel, remainingLabel])
        labels.axis = .vertical
        labels.spacing = 0
        let top = UIStackView(arrangedSubviews: [sprite, labels])
        top.spacing = 12
        top.alignment = .center
        let stack = UIStackView(arrangedSubviews: [top, totalBar])
        stack.axis = .vertical
        stack.spacing = 12
        card.addAutoLayoutSubviews(stack)
        stack.pinEdges(to: card, insets: UIEdgeInsets(top: 12, left: 12, bottom: 16, right: 16))
        NSLayoutConstraint.activate([
            sprite.widthAnchor.constraint(equalToConstant: 64),
            sprite.heightAnchor.constraint(equalToConstant: 64),
            totalBar.heightAnchor.constraint(equalToConstant: 6)
        ])
        card.isAccessibilityElement = true
        return card
    }

    fileprivate func makeStepSection() -> UIView {
        let caption = UILabel(fontSize: 13, weight: .semibold, color: Color.Grey400)
        caption.text = "EACH TAP ADDS"
        stepControl.selectedSegmentIndex = 0
        stepControl.selectedSegmentTintColor = Color.Orange500
        stepControl.backgroundColor = Color.Grey800
        stepControl.setTitleTextAttributes([.foregroundColor: Color.Grey900, .font: UIFont.monospacedDigitSystemFont(ofSize: 14, weight: .bold)], for: .selected)
        stepControl.setTitleTextAttributes([.foregroundColor: Color.Grey300, .font: UIFont.monospacedDigitSystemFont(ofSize: 14, weight: .medium)], for: .normal)
        stepControl.heightAnchor.constraint(equalToConstant: 34).isActive = true
        stepControl.accessibilityLabel = "EVs per tap"
        let hint = UILabel(fontSize: 12, color: Color.Grey500, lines: 0)
        hint.text = "1–3 per knockout · 8 with a Power item · 10 per vitamin"
        let stack = UIStackView(arrangedSubviews: [caption, stepControl, hint])
        stack.axis = .vertical
        stack.spacing = 6
        return stack
    }

    fileprivate func makeStatsCard() -> UIView {
        let card = UIView()
        card.backgroundColor = Color.Grey800
        card.layer.cornerRadius = 14
        let list = UIStackView()
        list.axis = .vertical
        list.spacing = 14
        for stat in Stat.allCases {
            let row = EVStatRow(stat: stat)
            row.onChange = { [weak self] amount in self?.change(stat, by: amount) }
            row.onValueTapped = { [weak self] in self?.promptExactValue(for: stat) }
            rows.append(row)
            list.addArrangedSubview(row)
        }
        card.addAutoLayoutSubviews(list)
        list.pinEdges(to: card, insets: UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 10))
        return card
    }

    // MARK: Changes

    fileprivate var step: Int {
        return EVTrainingVC.steps[stepControl.selectedSegmentIndex]
    }

    fileprivate func change(_ stat: Stat, by direction: Int) {
        let updated = caught.evs.adding(direction * step, to: stat)
        guard updated != caught.evs else {
            Haptics.playWarning()
            return
        }
        Haptics.tap()
        save(updated)
    }

    fileprivate func promptExactValue(for stat: Stat) {
        let ceiling = min(EffortValues.maximumPerStat, caught.evs[stat] + caught.evs.remaining)
        presentTextInput(title: stat.name,
                         message: "Enter a number from 0 to \(ceiling).",
                         text: "\(caught.evs[stat])",
                         placeholder: "EVs",
                         keyboardType: .numberPad,
                         isValid: { Int($0).map { (0...ceiling).contains($0) } ?? false }) { [weak self] value in
            guard let self = self, let number = Int(value) else { return }
            self.save(self.caught.evs.setting(number, for: stat))
        }
    }

    fileprivate func save(_ evs: EffortValues) {
        try? container.updateCatch.handle(UpdateCatchCommand(catchId: catchId, change: .evs(evs)))
        if let updated = container.getCatchDetails.handle(GetCatchDetailsQuery(catchId: catchId)) {
            caught = updated.summary
        }
        refresh()
    }

    @objc fileprivate func resetPressed() {
        presentDestructiveConfirmation(title: "Reset EVs?",
                                       message: "All of \(caught.pokemonName)'s EVs go back to 0.",
                                       destructiveTitle: "Reset") { [weak self] in
            self?.save(EffortValues())
        }
    }

    fileprivate func refresh() {
        let evs = caught.evs
        totalLabel.text = "\(evs.total) / \(EffortValues.maximumTotal)"
        remainingLabel.text = evs.remaining == 0 ? "Fully trained" : "\(evs.remaining) left to assign"
        totalBar.progress = Float(evs.total) / Float(EffortValues.maximumTotal)
        totalLabel.superview?.superview?.superview?.accessibilityLabel = "Total EVs \(evs.total) of \(EffortValues.maximumTotal), \(remainingLabel.text ?? "")"
        for row in rows {
            row.update(value: evs[row.stat], canIncrease: evs[row.stat] < EffortValues.maximumPerStat && evs.remaining > 0)
        }
        resetButton.isEnabled = !evs.isEmpty
    }
}

fileprivate class EVStatRow: UIView {
    let stat: Stat
    var onChange: ((Int) -> Void)?
    var onValueTapped: (() -> Void)?

    fileprivate let valueButton = UIButton(type: .system)
    fileprivate let bar = UIProgressView(progressViewStyle: .default)
    fileprivate let minusButton = UIButton(type: .system)
    fileprivate let plusButton = UIButton(type: .system)

    init(stat: Stat) {
        self.stat = stat
        super.init(frame: .zero)
        let nameLabel = UILabel(fontSize: 15, weight: .semibold)
        nameLabel.text = stat.name
        valueButton.titleLabel?.font = UIFont.monospacedDigitSystemFont(ofSize: 15, weight: .bold)
        valueButton.setTitleColor(Color.Grey100, for: .normal)
        valueButton.contentHorizontalAlignment = .right
        valueButton.addTarget(self, action: #selector(valueTapped), for: .touchUpInside)
        bar.trackTintColor = Color.Grey700
        bar.layer.cornerRadius = 3
        bar.clipsToBounds = true

        for (button, symbol, direction) in [(minusButton, "minus", -1), (plusButton, "plus", 1)] {
            button.setImage(UIImage.makeSymbol(symbol, pointSize: 15, weight: .bold), for: .normal)
            button.tintColor = Color.Grey200
            button.backgroundColor = Color.Grey700
            button.layer.cornerRadius = 18
            button.tag = direction
            button.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
            button.widthAnchor.constraint(equalToConstant: 36).isActive = true
            button.heightAnchor.constraint(equalToConstant: 36).isActive = true
        }
        minusButton.accessibilityLabel = "Remove \(stat.name) EVs"
        plusButton.accessibilityLabel = "Add \(stat.name) EVs"

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

    func update(value: Int, canIncrease: Bool) {
        valueButton.setTitle("\(value) / \(EffortValues.maximumPerStat)", for: .normal)
        valueButton.accessibilityLabel = "\(stat.name), \(value) EVs"
        valueButton.accessibilityHint = "Type an exact value."
        bar.progress = Float(value) / Float(EffortValues.maximumPerStat)
        bar.progressTintColor = value >= EffortValues.maximumPerStat ? Color.Orange500 : Color.Success500
        minusButton.isEnabled = value > 0
        plusButton.isEnabled = canIncrease
        minusButton.alpha = minusButton.isEnabled ? 1 : 0.4
        plusButton.alpha = plusButton.isEnabled ? 1 : 0.4
    }

    @objc fileprivate func buttonPressed(_ sender: UIButton) {
        onChange?(sender.tag)
    }

    @objc fileprivate func valueTapped() {
        onValueTapped?()
    }
}
