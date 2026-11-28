import UIKit

final class TrainingPlannerVC: UIViewController {
    fileprivate let container: AppContainer
    fileprivate let catchId: CatchID
    fileprivate let level: BattleLevel
    fileprivate let stack = UIStackView()
    fileprivate let spreadControl = UISegmentedControl(items: TrainingSpread.allCases.map { $0.shortTitle })
    fileprivate var spread: TrainingSpread?

    init(container: AppContainer, catchId: CatchID, level: BattleLevel) {
        self.container = container
        self.catchId = catchId
        self.level = level
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Training Plan"
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = Color.background
        spreadControl.addTarget(self, action: #selector(spreadChanged), for: .valueChanged)

        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        stack.axis = .vertical
        stack.spacing = Spacing.medium
        view.addAutoLayoutSubviews(scrollView)
        scrollView.pinEdges(to: view)
        scrollView.addAutoLayoutSubviews(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: Spacing.medium),
            stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -Spacing.extraLarge),
            stack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: Spacing.screenMargin),
            stack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -Spacing.screenMargin)
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        rebuild()
    }

    fileprivate func rebuild() {
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        guard let plan = container.getTrainingPlan.handle(GetTrainingPlanQuery(catchId: catchId, spread: spread, level: level)) else { return }
        spreadControl.selectedSegmentIndex = TrainingSpread.allCases.firstIndex(of: plan.spread) ?? 0
        stack.addArrangedSubview(spreadControl)
        stack.setCustomSpacing(Spacing.small, after: spreadControl)
        stack.addArrangedSubview(makeSpreadNote(plan))
        stack.setCustomSpacing(Spacing.large, after: stack.arrangedSubviews.last!)
        stack.addArrangedSubview(makeSummary(plan))
        stack.setCustomSpacing(Spacing.large, after: stack.arrangedSubviews.last!)
        stack.addArrangedSubview(SectionHeaderLabel(text: "Per stat"))
        stack.addArrangedSubview(makeStatsCard(plan))
        let footnote = UILabel(style: .caption1, color: Color.textQuaternary, lines: 0)
        footnote.text = makeFootnote(plan)
        stack.addArrangedSubview(footnote)
    }

    fileprivate func makeSpreadNote(_ plan: TrainingPlanDetails) -> UIView {
        let label = UILabel(style: .footnote, color: Color.textTertiary, lines: 0)
        let suggestion = plan.spread == plan.suggestedSpread
            ? "Suggested for its base stats and moves."
            : "Suggested: \(plan.suggestedSpread.title)."
        label.text = "\(plan.spread.summary) \(suggestion)"
        let wrapper = UIView()
        wrapper.addAutoLayoutSubviews(label)
        label.pinEdges(to: wrapper, insets: UIEdgeInsets(top: 0, left: Spacing.extraSmall, bottom: 0, right: Spacing.extraSmall))
        return wrapper
    }

    fileprivate func makeSummary(_ plan: TrainingPlanDetails) -> UIView {
        let target = plan.stats.filter { $0.target > 0 }.sorted { $0.target > $1.target }.map { "\($0.target) \($0.stat.shortName)" }.joined(separator: " / ")
        let left = StatTile(caption: "Left to train", value: plan.isComplete ? "Done" : "\(plan.remaining)",
                            detail: plan.isComplete ? "Matches the plan" : plan.remaining == 1 ? "EV" : "EVs")
        let second = plan.excess > 0
            ? StatTile(caption: "To remove", value: "\(plan.excess)", detail: "EVs outside the plan")
            : StatTile(caption: "Target", value: plan.spread.shortTitle, detail: target)
        let row = UIStackView(arrangedSubviews: [left, second])
        row.distribution = .fillEqually
        row.spacing = 10
        return row
    }

    fileprivate func makeStatsCard(_ plan: TrainingPlanDetails) -> UIView {
        let rows = UIStackView(arrangedSubviews: plan.stats.map { TrainingStatRow(plan: $0, level: plan.level) })
        rows.axis = .vertical
        rows.spacing = Spacing.medium
        let card = UIView()
        card.backgroundColor = Color.surface
        card.layer.cornerRadius = CornerRadius.standard
        card.addAutoLayoutSubviews(rows)
        rows.pinEdges(to: card, insets: UIEdgeInsets(top: Spacing.medium, left: Spacing.medium, bottom: Spacing.medium, right: Spacing.medium))
        return card
    }

    fileprivate func makeFootnote(_ plan: TrainingPlanDetails) -> String {
        var notes = ["Stats are shown at level \(plan.level.rawValue), before and after the plan."]
        if plan.excess > 0 {
            notes.append("EV-reducing berries lower a stat's EVs so they can go where the plan needs them.")
        }
        return notes.joined(separator: " ")
    }

    @objc fileprivate func spreadChanged() {
        spread = TrainingSpread.allCases[spreadControl.selectedSegmentIndex]
        rebuild()
    }
}

fileprivate final class TrainingStatRow: UIView {
    init(plan: TrainingStatPlan, level: BattleLevel) {
        super.init(frame: .zero)
        let isDone = plan.remaining == 0 && plan.excess == 0
        let nameLabel = UILabel(style: .subheadline, weight: .semibold)
        nameLabel.text = plan.stat.name
        let valueLabel = UILabel(style: .footnote, color: Color.textTertiary)
        valueLabel.font = UIFont.make(.footnote, monospacedDigits: true)
        valueLabel.text = TrainingStatRow.formatValues(plan)
        let names = UIStackView(arrangedSubviews: [nameLabel, valueLabel])
        names.axis = .vertical
        names.spacing = 2

        let evLabel = UILabel(style: .subheadline, weight: .bold, color: isDone && plan.target > 0 ? Color.success : Color.textPrimary)
        evLabel.font = UIFont.make(.subheadline, weight: .bold, monospacedDigits: true)
        evLabel.text = "\(plan.current) / \(plan.target)"
        evLabel.textAlignment = .right
        let statusLabel = UILabel(style: .footnote, weight: .semibold, color: TrainingStatRow.findStatusColor(plan))
        statusLabel.text = TrainingStatRow.formatStatus(plan)
        statusLabel.textAlignment = .right
        let evs = UIStackView(arrangedSubviews: [evLabel, statusLabel])
        evs.axis = .vertical
        evs.alignment = .trailing
        evs.spacing = 2
        evs.setContentCompressionResistancePriority(.required, for: .horizontal)
        evs.setContentHuggingPriority(.required, for: .horizontal)

        let header = UIStackView(arrangedSubviews: [names, evs])
        header.alignment = .center
        header.spacing = Spacing.small

        let bar = UIProgressView(progressViewStyle: .default)
        bar.progress = plan.excess > 0 ? 1 : plan.target > 0 ? Float(plan.current) / Float(plan.target) : 0
        bar.progressTintColor = plan.excess > 0 ? Color.danger : isDone ? Color.success : Color.accent
        bar.trackTintColor = Color.surfaceRaised
        bar.layer.cornerRadius = CornerRadius.tiny
        bar.clipsToBounds = true
        bar.isAccessibilityElement = false

        let content = UIStackView(arrangedSubviews: [header, bar])
        content.axis = .vertical
        content.spacing = Spacing.small
        addAutoLayoutSubviews(content)
        content.pinEdges(to: self)
        bar.heightAnchor.constraint(equalToConstant: 6).isActive = true

        isAccessibilityElement = true
        accessibilityLabel = [plan.stat.name, "\(plan.current) of \(plan.target) EVs", TrainingStatRow.formatStatus(plan), TrainingStatRow.formatValues(plan)]
            .compactMap { $0 }.joined(separator: ", ")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate static func formatStatus(_ plan: TrainingStatPlan) -> String {
        if plan.excess > 0 {
            return "Lower by \(plan.excess)"
        }
        if plan.remaining > 0 {
            return "\(plan.remaining) to go"
        }
        return plan.target > 0 ? "Done" : "Leave at 0"
    }

    fileprivate static func findStatusColor(_ plan: TrainingStatPlan) -> UIColor {
        if plan.excess > 0 {
            return Color.danger
        }
        if plan.remaining > 0 {
            return Color.accent
        }
        return plan.target > 0 ? Color.success : Color.textQuaternary
    }

    fileprivate static func formatValues(_ plan: TrainingStatPlan) -> String? {
        guard let value = plan.value, let plannedValue = plan.plannedValue else { return nil }
        return value == plannedValue ? "\(value)" : "\(value) → \(plannedValue)"
    }
}

extension TrainingSpread {
    var title: String {
        switch self {
        case .fastAttacker: return "Fast attacker"
        case .bulkyAttacker: return "Bulky attacker"
        case .wall: return "Wall"
        }
    }

    var shortTitle: String {
        switch self {
        case .fastAttacker: return "Fast"
        case .bulkyAttacker: return "Bulky"
        case .wall: return "Wall"
        }
    }

    var summary: String {
        switch self {
        case .fastAttacker: return "Maxes its attacking stat and Speed to hit hard and move first."
        case .bulkyAttacker: return "Maxes HP and its attacking stat, for slow hitters and Trick Room."
        case .wall: return "Maxes HP and its stronger defense to take hits."
        }
    }
}
