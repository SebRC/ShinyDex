import UIKit

class IVEditorVC: UIViewController {
    fileprivate let container: AppContainer
    fileprivate let catchId: CatchID
    fileprivate var caught: CatchSummary
    fileprivate let perfectLabel = UILabel(fontSize: 34, weight: .bold, color: Color.Grey100)
    fileprivate let summaryLabel = UILabel(fontSize: 13, color: Color.Grey400)
    fileprivate var rows = [IVStatRow]()
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
        title = "IVs"
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = Color.Grey900
        resetButton = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(resetPressed))
        navigationItem.rightBarButtonItem = resetButton

        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        let stack = UIStackView(arrangedSubviews: [makeSummaryCard(), makeStatsCard()])
        stack.axis = .vertical
        stack.spacing = 16
        let footnote = UILabel(fontSize: 12, color: Color.Grey500, lines: 0)
        footnote.text = "Each stat has an IV from 0 to 31. Tap a number to type an exact value, or leave it empty if you don't know it."
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

    fileprivate func makeSummaryCard() -> UIView {
        let card = UIView()
        card.backgroundColor = Color.Grey800
        card.layer.cornerRadius = 14
        let sprite = UIImageView(image: caught.spriteImage)
        sprite.contentMode = .scaleAspectFit
        sprite.layer.magnificationFilter = .nearest
        sprite.isAccessibilityElement = false
        let caption = UILabel(fontSize: 12, weight: .semibold, color: Color.Grey400)
        caption.text = "PERFECT IVS"
        perfectLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 34, weight: .bold)
        summaryLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 13, weight: .regular)

        let labels = UIStackView(arrangedSubviews: [caption, perfectLabel, summaryLabel])
        labels.axis = .vertical
        let content = UIStackView(arrangedSubviews: [sprite, labels])
        content.spacing = 12
        content.alignment = .center
        card.addAutoLayoutSubviews(content)
        content.pinEdges(to: card, insets: UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 16))
        NSLayoutConstraint.activate([
            sprite.widthAnchor.constraint(equalToConstant: 64),
            sprite.heightAnchor.constraint(equalToConstant: 64)
        ])
        card.isAccessibilityElement = true
        return card
    }

    fileprivate func makeStatsCard() -> UIView {
        let card = UIView()
        card.backgroundColor = Color.Grey800
        card.layer.cornerRadius = 14
        let list = UIStackView()
        list.axis = .vertical
        list.spacing = 14
        for stat in Stat.allCases {
            let row = IVStatRow(stat: stat)
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

    fileprivate func change(_ stat: Stat, by direction: Int) {
        let target = caught.ivs[stat].map { $0 + direction } ?? IndividualValues.range.lowerBound
        guard IndividualValues.range.contains(target) else {
            Haptics.playWarning()
            return
        }
        Haptics.tap()
        save(caught.ivs.setting(target, for: stat))
    }

    fileprivate func promptExactValue(for stat: Stat) {
        let range = IndividualValues.range
        presentTextInput(title: stat.name,
                         message: "Enter a number from \(range.lowerBound) to \(range.upperBound), or leave it empty if you don't know it.",
                         text: caught.ivs[stat].map(String.init),
                         placeholder: "Unknown",
                         keyboardType: .numberPad,
                         isValid: { $0.isEmpty || (Int($0).map { range.contains($0) } ?? false) }) { [weak self] value in
            guard let self = self else { return }
            self.save(self.caught.ivs.setting(Int(value), for: stat))
        }
    }

    fileprivate func save(_ ivs: IndividualValues) {
        try? container.updateCatch.handle(UpdateCatchCommand(catchId: catchId, change: .ivs(ivs)))
        if let updated = container.getCatchDetails.handle(GetCatchDetailsQuery(catchId: catchId)) {
            caught = updated.summary
        }
        refresh()
    }

    @objc fileprivate func resetPressed() {
        presentDestructiveConfirmation(title: "Reset IVs?",
                                       message: "All of \(caught.pokemonName)'s IVs go back to unknown.",
                                       destructiveTitle: "Reset") { [weak self] in
            self?.save(IndividualValues())
        }
    }

    fileprivate func refresh() {
        let ivs = caught.ivs
        perfectLabel.text = "\(ivs.perfectCount) / \(Stat.allCases.count)"
        summaryLabel.attributedText = ivs.makeColoredSummary(unknownColor: Color.Grey400)
        perfectLabel.superview?.superview?.superview?.accessibilityLabel = "Perfect IVs \(ivs.perfectCount) of \(Stat.allCases.count), \(ivs.summary)"
        for row in rows {
            row.update(value: ivs[row.stat])
        }
        resetButton.isEnabled = !ivs.isEmpty
    }
}

fileprivate class IVStatRow: UIView {
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
        minusButton.accessibilityLabel = "Lower \(stat.name) IV"
        plusButton.accessibilityLabel = "Raise \(stat.name) IV"

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

    func update(value: Int?) {
        let maximum = IndividualValues.range.upperBound
        valueButton.setTitle(value.map { "\($0) / \(maximum)" } ?? "Unknown", for: .normal)
        valueButton.setTitleColor(value.map(IndividualValues.getColor(for:)) ?? Color.Grey400, for: .normal)
        valueButton.accessibilityLabel = "\(stat.name), \(value.map { "\($0) IV" } ?? "unknown IV")"
        valueButton.accessibilityHint = "Type an exact value."
        bar.progress = Float(value ?? 0) / Float(maximum)
        bar.progressTintColor = value.map(IndividualValues.getColor(for:))
        minusButton.isEnabled = value.map { $0 > IndividualValues.range.lowerBound } ?? false
        plusButton.isEnabled = value.map { $0 < maximum } ?? true
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
