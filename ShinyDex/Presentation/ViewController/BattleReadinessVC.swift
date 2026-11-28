import UIKit

final class BattleReadinessVC: UIViewController {
    fileprivate let container: AppContainer
    fileprivate let level: BattleLevel
    fileprivate var battler: BattlerSummary
    fileprivate let stack = UIStackView()

    init(container: AppContainer, battler: BattlerSummary, level: BattleLevel) {
        self.container = container
        self.battler = battler
        self.level = level
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Battle Readiness"
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = Color.background
        let detailsButton = UIBarButtonItem(image: UIImage(systemName: "info.circle"), style: .plain, target: self, action: #selector(detailsPressed))
        detailsButton.accessibilityLabel = "Catch details"
        navigationItem.rightBarButtonItem = detailsButton

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
        reloadBattler()
        rebuild()
    }

    fileprivate func reloadBattler() {
        let rankings = container.rankBattlers.handle(RankBattlersQuery(ranking: .readiness, level: level, showsBestOfEachSpecies: false))
        if let updated = rankings.battlers.first(where: { $0.id == battler.id }) {
            battler = updated
        }
    }

    fileprivate func rebuild() {
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        stack.addArrangedSubview(makeSummaryCard())
        stack.setCustomSpacing(Spacing.large, after: stack.arrangedSubviews.last!)
        stack.addArrangedSubview(SectionHeaderLabel(text: "Breakdown"))
        for part in battler.readinessParts {
            let onPlanTraining: (() -> Void)? = part.factor == .evs ? { [weak self] in self?.showTrainingPlan() } : nil
            stack.addArrangedSubview(ReadinessPartCard(part: part, battler: battler, onPlanTraining: onPlanTraining))
        }
        let footnote = UILabel(style: .caption1, color: Color.textQuaternary, lines: 0)
        footnote.text = makeFootnote()
        stack.addArrangedSubview(footnote)
    }

    fileprivate func makeSummaryCard() -> UIView {
        let sprite = UIImageView(image: PokemonSprites.makeImage(pokemonName: battler.pokemonName, formId: battler.formId))
        sprite.contentMode = .scaleAspectFit
        sprite.layer.magnificationFilter = .nearest
        sprite.isAccessibilityElement = false
        let titleLabel = UILabel(style: .body, weight: .semibold)
        titleLabel.text = battler.title
        let detailsLabel = UILabel(style: .footnote, color: Color.textTertiary, lines: 0)
        detailsLabel.attributedText = battler.makeDetails(textColor: Color.textTertiary, font: UIFont.make(.footnote))
        let names = UIStackView(arrangedSubviews: [titleLabel, detailsLabel])
        names.axis = .vertical
        names.spacing = 2

        let scoreLabel = UILabel(style: .largeTitle, weight: .bold, color: Color.accent)
        scoreLabel.font = UIFont.make(.largeTitle, weight: .bold, monospacedDigits: true)
        scoreLabel.text = "\(battler.readiness)"
        let maximumLabel = UILabel(style: .subheadline, weight: .semibold, color: Color.textTertiary)
        maximumLabel.text = "/ \(battler.readinessParts.map { $0.maximum }.reduce(0, +))"
        let scoreRow = UIStackView(arrangedSubviews: [scoreLabel, maximumLabel])
        scoreRow.spacing = Spacing.extraSmall
        scoreRow.alignment = .firstBaseline
        let caption = UILabel(style: .caption2, weight: .semibold, color: Color.textTertiary)
        caption.text = "READINESS"
        let score = UIStackView(arrangedSubviews: [scoreRow, caption])
        score.axis = .vertical
        score.alignment = .trailing
        score.isAccessibilityElement = true
        score.accessibilityLabel = "Readiness \(battler.readiness) out of 100"
        for view in [score, scoreLabel, maximumLabel] {
            view.setContentCompressionResistancePriority(.required, for: .horizontal)
            view.setContentHuggingPriority(.required, for: .horizontal)
        }

        let identity = UIStackView(arrangedSubviews: [sprite, names, score])
        identity.alignment = .center
        identity.spacing = Spacing.medium

        let badgesLabel = UILabel(style: .caption1, lines: 0)
        badgesLabel.attributedText = battler.makeBadgeText(font: UIFont.make(.caption1, weight: .semibold))
        badgesLabel.isHidden = battler.badges.isEmpty

        let content = UIStackView(arrangedSubviews: [identity, badgesLabel])
        content.axis = .vertical
        content.spacing = Spacing.medium
        let card = UIView()
        card.backgroundColor = Color.surface
        card.layer.cornerRadius = CornerRadius.standard
        card.addAutoLayoutSubviews(content)
        content.pinEdges(to: card, insets: UIEdgeInsets(top: Spacing.medium, left: Spacing.medium, bottom: Spacing.medium, right: Spacing.medium))
        NSLayoutConstraint.activate([
            sprite.widthAnchor.constraint(equalToConstant: 64),
            sprite.heightAnchor.constraint(equalToConstant: 64)
        ])
        return card
    }

    fileprivate func makeFootnote() -> String {
        var notes = ["Readiness adds up the nature, IVs, EVs, moves and ability, out of 100."]
        if let lessRelevantStat = battler.style.lessRelevantStat {
            notes.append("Its moves don't use \(lessRelevantStat.name), so that IV counts a quarter.")
        }
        return notes.joined(separator: " ")
    }

    fileprivate func showTrainingPlan() {
        navigationController?.pushViewController(TrainingPlannerVC(container: container, catchId: battler.id, level: level), animated: true)
    }

    @objc fileprivate func detailsPressed() {
        guard let detail = CatchDetailTVC(container: container, catchId: battler.id) else { return }
        navigationController?.pushViewController(detail, animated: true)
    }
}

fileprivate final class ReadinessPartCard: UIView {
    fileprivate var onPlanTraining: (() -> Void)?

    init(part: ReadinessPart, battler: BattlerSummary, onPlanTraining: (() -> Void)? = nil) {
        self.onPlanTraining = onPlanTraining
        super.init(frame: .zero)
        backgroundColor = Color.surface
        layer.cornerRadius = CornerRadius.standard

        let isComplete = part.earned >= part.maximum
        let titleLabel = UILabel(style: .subheadline, weight: .semibold)
        titleLabel.text = part.factor.title
        let detailLabel = UILabel(style: .footnote, color: Color.textTertiary)
        detailLabel.text = part.factor.makeDetail(for: battler)
        let scoreLabel = UILabel(style: .subheadline, weight: .bold, color: isComplete ? Color.success : Color.textPrimary)
        scoreLabel.font = UIFont.make(.subheadline, weight: .bold, monospacedDigits: true)
        scoreLabel.text = "\(part.earned)/\(part.maximum)"
        scoreLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        scoreLabel.setContentHuggingPriority(.required, for: .horizontal)
        let titles = UIStackView(arrangedSubviews: [titleLabel, detailLabel])
        titles.axis = .vertical
        titles.spacing = 2
        let header = UIStackView(arrangedSubviews: [titles, scoreLabel])
        header.alignment = .center
        header.spacing = Spacing.small

        let bar = UIProgressView(progressViewStyle: .default)
        bar.progress = part.maximum > 0 ? Float(part.earned) / Float(part.maximum) : 0
        bar.progressTintColor = isComplete ? Color.success : Color.accent
        bar.trackTintColor = Color.surfaceRaised
        bar.layer.cornerRadius = CornerRadius.tiny
        bar.clipsToBounds = true
        bar.isAccessibilityElement = false

        let lines = part.improvements.isEmpty
            ? [ReadinessPartCard.makeLine(text: "Full marks", symbolName: "checkmark.circle.fill", color: Color.success)]
            : part.improvements.map { ReadinessPartCard.makeLine(text: $0.message, symbolName: "arrow.up.circle.fill", color: Color.accent) }
        let content = UIStackView(arrangedSubviews: [header, bar] + lines)
        content.axis = .vertical
        content.spacing = Spacing.small
        content.setCustomSpacing(Spacing.medium, after: bar)
        if onPlanTraining != nil {
            let planButton = UIButton.make(.tinted, title: "Plan EV training", symbolName: "list.bullet.clipboard", typeStyle: .subheadline, symbolSize: 14)
            planButton.addTarget(self, action: #selector(planTrainingPressed), for: .touchUpInside)
            content.addArrangedSubview(planButton)
            content.setCustomSpacing(Spacing.medium, after: content.arrangedSubviews[content.arrangedSubviews.count - 2])
        }
        addAutoLayoutSubviews(content)
        content.pinEdges(to: self, insets: UIEdgeInsets(top: Spacing.medium, left: Spacing.medium, bottom: Spacing.medium, right: Spacing.medium))
        bar.heightAnchor.constraint(equalToConstant: 6).isActive = true

        isAccessibilityElement = onPlanTraining == nil
        accessibilityLabel = ([part.factor.title, part.factor.makeDetail(for: battler), "\(part.earned) of \(part.maximum) points"].compactMap { $0 }
            + (part.improvements.isEmpty ? ["Full marks"] : part.improvements.map { $0.message })).joined(separator: ", ")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc fileprivate func planTrainingPressed() {
        onPlanTraining?()
    }

    fileprivate static func makeLine(text: String, symbolName: String, color: UIColor) -> UIView {
        let icon = UIImageView(image: UIImage(systemName: symbolName, withConfiguration: UIImage.SymbolConfiguration(font: UIFont.make(.footnote, weight: .semibold))))
        icon.tintColor = color
        icon.setContentHuggingPriority(.required, for: .horizontal)
        icon.setContentCompressionResistancePriority(.required, for: .horizontal)
        let label = UILabel(style: .footnote, color: Color.textSecondary, lines: 0)
        label.text = text
        let line = UIStackView(arrangedSubviews: [icon, label])
        line.spacing = Spacing.small
        line.alignment = .firstBaseline
        return line
    }
}

extension ReadinessFactor {
    var title: String {
        switch self {
        case .nature: return "Nature"
        case .ivs: return "IVs"
        case .evs: return "EVs"
        case .moves: return "Moves"
        case .ability: return "Ability"
        }
    }

    func makeDetail(for battler: BattlerSummary) -> String? {
        switch self {
        case .nature: return battler.nature.map { "\($0.name) (\($0.effectSummary))" } ?? "Not logged"
        case .ivs: return "\(battler.relevantIVPercent)% of the IVs that matter"
        case .evs:
            let total = battler.stats.map { $0.ev }.reduce(0, +)
            return "\(total) of \(EffortValues.maximumTotal) EVs"
        case .moves: return nil
        case .ability: return battler.ability ?? "Not logged"
        }
    }
}

extension ReadinessImprovement {
    var message: String {
        switch self {
        case .logNature:
            return "Log its nature."
        case .changeNature(let stat, let usesMint):
            return usesMint ? "A nature that lowers \(stat.name) scores full points. A mint can give it one." : "A nature that lowers \(stat.name) scores full points."
        case .commitToOneAttackingStat:
            return "Only a nature that lowers the attacking stat it doesn't use scores full points, so give it moves that use just Attack or just Sp. Atk."
        case .logIVs(let stats):
            return "Log its \(BattleReadinessFormatting.makeList(of: stats)) \(stats.count == 1 ? "IV" : "IVs")."
        case .raiseIVs(let stats, let usesHyperTraining):
            let names = BattleReadinessFormatting.makeList(of: stats)
            return usesHyperTraining ? "Hyper Train \(names) to 31." : "\(names) \(stats.count == 1 ? "isn't" : "aren't") at 31, and this game has no Hyper Training."
        case .trainEVs(let remaining):
            return "Train \(remaining) more EVs."
        case .moveWastedEVs(let amount):
            return "\(amount) EVs are past 252 in one stat and do nothing. Move them to another stat."
        case .teachMoves(let count):
            return count == 1 ? "Log 1 more move." : "Log \(count) more moves."
        case .logAbility:
            return "Log its ability."
        }
    }
}

fileprivate enum BattleReadinessFormatting {
    static func makeList(of stats: [Stat]) -> String {
        return ListFormatter.localizedString(byJoining: stats.map { $0.name })
    }
}
