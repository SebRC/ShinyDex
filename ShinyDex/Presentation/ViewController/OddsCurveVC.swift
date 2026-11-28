import UIKit

final class OddsCurveVC: UIViewController {
    fileprivate let container: AppContainer
    fileprivate let number: Int
    fileprivate let stack = UIStackView()
    fileprivate let chanceTile = StatTile(caption: "Chance so far")
    fileprivate let oddsTile = StatTile(caption: "Shiny odds")
    fileprivate let curveView = OddsCurveView()
    fileprivate let milestoneRows = UIStackView()
    fileprivate let footnoteLabel = UILabel(style: .footnote, color: Color.textTertiary, lines: 0)
    fileprivate let paceLabel = UILabel(style: .footnote, color: Color.textTertiary, lines: 0)

    init(container: AppContainer, number: Int) {
        self.container = container
        self.number = number
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Odds Curve"
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = Color.background

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

        let tiles = UIStackView(arrangedSubviews: [chanceTile, oddsTile])
        tiles.distribution = .fillEqually
        tiles.spacing = Spacing.medium
        milestoneRows.axis = .vertical
        stack.addArrangedSubview(tiles)
        stack.setCustomSpacing(Spacing.large, after: tiles)
        stack.addArrangedSubview(SectionHeaderLabel(text: "Chance by encounters"))
        stack.addArrangedSubview(makeCard(containing: curveView, insets: UIEdgeInsets(top: Spacing.small, left: Spacing.small, bottom: Spacing.small, right: Spacing.small)))
        let hint = UILabel(style: .footnote, color: Color.textTertiary, lines: 0)
        hint.text = "Touch and drag the curve to read any point."
        stack.addArrangedSubview(hint)
        stack.setCustomSpacing(Spacing.large, after: hint)
        stack.addArrangedSubview(SectionHeaderLabel(text: "Milestones"))
        stack.addArrangedSubview(makeCard(containing: milestoneRows, insets: UIEdgeInsets(top: Spacing.extraSmall, left: 0, bottom: Spacing.extraSmall, right: 0)))
        stack.addArrangedSubview(paceLabel)
        stack.addArrangedSubview(footnoteLabel)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadCurve()
    }

    fileprivate func reloadCurve() {
        guard let summary = container.getOddsCurve.handle(GetOddsCurveQuery(number: number)) else { return }
        chanceTile.setValue(CatchLuckText.formatPercent(summary.current.chance), isEmphasized: true)
        chanceTile.setDetail("after \(summary.current.encounters.grouped)")
        oddsTile.setValue("1/\(summary.shinyOdds.grouped)")
        oddsTile.accessibilityValue = "1 in \(summary.shinyOdds.grouped)"
        curveView.update(summary: summary)
        milestoneRows.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for milestone in summary.milestones {
            milestoneRows.addArrangedSubview(OddsCurveVC.makeMilestoneRow(milestone, encounters: summary.current.encounters))
        }
        paceLabel.text = OddsCurveVC.makePaceText(summary.pace)
        footnoteLabel.text = summary.usesChain
            ? "Assumes your chain keeps going unbroken from here, with the odds improving as it grows."
            : "Each encounter is an independent roll, so the curve shows the share of hunts that would have found the shiny by then."
    }

    fileprivate func makeCard(containing content: UIView, insets: UIEdgeInsets) -> UIView {
        let card = UIView()
        card.backgroundColor = Color.surface
        card.layer.cornerRadius = CornerRadius.standard
        card.addAutoLayoutSubviews(content)
        content.pinEdges(to: card, insets: insets)
        return card
    }

    fileprivate static func makePaceText(_ pace: HuntForecast?) -> String {
        guard let pace = pace else {
            return "Days to each milestone appear once you've hunted this Pokémon in the last \(HuntPace.windowDays) days."
        }
        let days = pace.activeDays == 1 ? "the 1 day" : "the \(pace.activeDays) days"
        return "Days are estimated from your pace of about \(pace.encountersPerDay.grouped) encounters a day, over \(days) you hunted it in the last \(HuntPace.windowDays)."
    }

    fileprivate static func makeMilestoneRow(_ milestone: OddsCurveMilestone, encounters: Int) -> UIView {
        let chanceLabel = UILabel(style: .body, weight: .bold, color: Color.textPrimary)
        chanceLabel.font = UIFont.make(.body, weight: .bold, monospacedDigits: true)
        chanceLabel.text = "\(Int(milestone.chance))%"
        chanceLabel.setContentHuggingPriority(.required, for: .horizontal)
        let encountersLabel = UILabel(style: .subheadline, color: Color.textSecondary)
        encountersLabel.text = "by \(milestone.encounters.grouped)"
        encountersLabel.adjustsFontSizeToFitWidth = true
        encountersLabel.minimumScaleFactor = 0.8
        let isReached = encounters >= milestone.encounters
        let remainingLabel = UILabel(style: .subheadline, weight: .semibold, color: isReached ? Color.success : Color.textTertiary)
        remainingLabel.font = UIFont.make(.subheadline, weight: .semibold, monospacedDigits: true)
        remainingLabel.text = isReached ? "Reached" : "\((milestone.encounters - encounters).grouped) to go"
        remainingLabel.textAlignment = .right
        let daysLabel = UILabel(style: .caption1, color: Color.textTertiary)
        daysLabel.font = UIFont.make(.caption1, monospacedDigits: true)
        daysLabel.textAlignment = .right
        daysLabel.text = milestone.daysToReach.map { $0 == 1 ? "~1 day" : "~\($0.grouped) days" }
        daysLabel.isHidden = isReached || daysLabel.text == nil
        let remaining = UIStackView(arrangedSubviews: [remainingLabel, daysLabel])
        remaining.axis = .vertical
        remaining.alignment = .trailing
        remaining.setContentHuggingPriority(.required, for: .horizontal)
        let icon = UIImageView(image: UIImage.makeSymbol(isReached ? "checkmark.circle.fill" : "circle", pointSize: 15, weight: .semibold))
        icon.tintColor = isReached ? Color.success : Color.textQuaternary
        icon.contentMode = .center
        icon.setContentHuggingPriority(.required, for: .horizontal)
        icon.setContentCompressionResistancePriority(.required, for: .horizontal)
        let row = UIStackView(arrangedSubviews: [icon, chanceLabel, encountersLabel, remaining])
        row.spacing = Spacing.medium
        row.alignment = .center
        row.isLayoutMarginsRelativeArrangement = true
        row.layoutMargins = UIEdgeInsets(top: Spacing.medium, left: Spacing.large, bottom: Spacing.medium, right: Spacing.large)
        row.isAccessibilityElement = true
        row.accessibilityLabel = (["\(Int(milestone.chance)) percent chance by \(milestone.encounters.grouped) encounters", remainingLabel.text] + (daysLabel.isHidden ? [] : [daysLabel.text.map { "about \($0.dropFirst())" }])).compactMap { $0 }.joined(separator: ", ")
        return row
    }
}
