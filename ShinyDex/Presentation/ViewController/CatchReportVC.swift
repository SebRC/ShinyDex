import UIKit

final class CatchReportVC: UIViewController {
    fileprivate static let spriteSize: CGFloat = 132
    fileprivate static let revealStagger: TimeInterval = 0.08

    fileprivate let container: AppContainer
    fileprivate let report: CatchReport
    fileprivate let sprite = UIImageView()
    fileprivate let stack = UIStackView()
    fileprivate var revealedViews = [UIView]()
    fileprivate var hasCelebrated = false

    init?(container: AppContainer, catchId: CatchID) {
        guard let report = container.getCatchReport.handle(GetCatchReportQuery(catchId: catchId)) else { return nil }
        self.container = container
        self.report = report
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Catch Report"
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
        buildContent()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !hasCelebrated else { return }
        hasCelebrated = true
        celebrate()
    }

    // MARK: Content

    fileprivate func buildContent() {
        stack.addArrangedSubview(makeHero())
        stack.setCustomSpacing(Spacing.large, after: stack.arrangedSubviews.last!)
        addRow(makeEncountersTile(), makeLuckTile())
        addRow(makeLengthTile(), makeRankTile())
        if !report.phases.isEmpty {
            addReveal(SectionHeaderLabel(text: report.phases.count == 1 ? "1 phase on the way" : "\(report.phases.count) phases on the way"))
            addReveal(makePhasesCard())
        }
        let doneButton = UIButton.make(.primary, title: "Done")
        doneButton.addTarget(self, action: #selector(donePressed), for: .touchUpInside)
        stack.setCustomSpacing(Spacing.extraLarge, after: stack.arrangedSubviews.last!)
        addReveal(doneButton)
    }

    fileprivate func makeHero() -> UIView {
        let caught = report.caught
        sprite.image = PokemonSprites.makeImage(pokemonName: caught.pokemonName, formId: caught.formId)
        sprite.contentMode = .scaleAspectFit
        sprite.layer.magnificationFilter = .nearest
        sprite.isAccessibilityElement = false

        let titleLabel = UILabel(style: .title1, weight: .bold, color: Color.accent)
        titleLabel.text = "Shiny \(PokemonSprites.makeTitle(pokemonName: caught.pokemonName, formName: caught.formName))!"
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        let countLabel = UILabel(style: .subheadline, weight: .semibold, color: Color.textSecondary)
        countLabel.text = makeCountText()
        countLabel.textAlignment = .center

        let ball = UIImageView(image: UIImage(named: caught.caughtBall))
        ball.contentMode = .scaleAspectFit
        ball.layer.magnificationFilter = .nearest
        let detailLabel = UILabel(style: .footnote, color: Color.textTertiary)
        detailLabel.text = [caught.ballName, caught.game.displayName, caught.formattedCaughtDate].compactMap { $0 }.joined(separator: " · ")
        let detailRow = UIStackView(arrangedSubviews: [ball, detailLabel])
        detailRow.spacing = Spacing.extraSmall
        detailRow.alignment = .center

        let hero = UIStackView(arrangedSubviews: [sprite, titleLabel, countLabel, detailRow])
        hero.axis = .vertical
        hero.alignment = .center
        hero.spacing = Spacing.extraSmall
        hero.setCustomSpacing(Spacing.small, after: sprite)
        if !UIAccessibility.isReduceMotionEnabled {
            sprite.alpha = 0
            sprite.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        }
        hero.isAccessibilityElement = true
        hero.accessibilityLabel = [titleLabel.text, countLabel.text, detailLabel.text].compactMap { $0 }.joined(separator: ", ")
        NSLayoutConstraint.activate([
            sprite.widthAnchor.constraint(equalToConstant: CatchReportVC.spriteSize),
            sprite.heightAnchor.constraint(equalToConstant: CatchReportVC.spriteSize),
            ball.widthAnchor.constraint(equalToConstant: 18),
            ball.heightAnchor.constraint(equalToConstant: 18)
        ])
        return hero
    }

    fileprivate func makeCountText() -> String {
        let speciesText = report.speciesCatchNumber == 1
            ? "Your first \(report.caught.pokemonName)"
            : "Your \(CatchReportVC.formatOrdinal(report.speciesCatchNumber)) \(report.caught.pokemonName)"
        return "\(speciesText) · Shiny #\(report.shinyNumber.grouped)"
    }

    fileprivate func makeEncountersTile() -> StatTile {
        let encounters = report.caught.encounters
        guard let odds = report.odds, encounters > 0 else {
            return StatTile(caption: "Encounters", value: encounters.grouped, detail: report.caught.huntMethod.rawValue)
        }
        let ratio = Double(encounters) / Double(odds)
        return StatTile(caption: "Encounters", value: encounters.grouped, detail: "\(String(format: "%.1f", ratio))× the odds of 1/\(odds.grouped)")
    }

    fileprivate func makeLuckTile() -> StatTile {
        guard let chance = report.chanceOfFindingSooner else {
            return StatTile(caption: "Luck", value: "–", detail: "Not known for this method")
        }
        return StatTile(caption: "Luck", value: CatchLuckText.formatRank(chanceOfFindingSooner: chance), detail: CatchLuckText.describe(chanceOfFindingSooner: chance),
                        isValueEmphasized: chance <= 50)
    }

    fileprivate func makeLengthTile() -> StatTile {
        guard let days = report.daysHunted, let activeDays = report.activeDays else {
            return StatTile(caption: "Hunt length", value: "–", detail: "No daily encounters tracked for it")
        }
        let detail = activeDays == days ? (days == 1 ? "All in one day" : "Hunted every day") : "Hunted on \(activeDays) of them"
        return StatTile(caption: "Hunt length", value: days == 1 ? "1 day" : "\(days.grouped) days", detail: detail)
    }

    fileprivate func makeRankTile() -> StatTile {
        guard let rank = report.encounterRank, report.rankedHuntCount > 1 else {
            return StatTile(caption: "Rank", value: "–", detail: "Needs more hunts to compare")
        }
        let value = rank == 1 ? "Fastest" : CatchReportVC.formatOrdinal(rank)
        return StatTile(caption: "Rank", value: value, detail: "By fewest encounters, of \(report.rankedHuntCount) hunts")
    }

    fileprivate func makePhasesCard() -> UIView {
        let rows = UIStackView(arrangedSubviews: report.phases.map(CatchReportVC.makePhaseRow))
        rows.axis = .vertical
        rows.spacing = Spacing.small
        let card = UIView()
        card.backgroundColor = Color.surface
        card.layer.cornerRadius = CornerRadius.standard
        card.addAutoLayoutSubviews(rows)
        rows.pinEdges(to: card, insets: UIEdgeInsets(top: Spacing.medium, left: Spacing.medium, bottom: Spacing.medium, right: Spacing.medium))
        return card
    }

    fileprivate static func makePhaseRow(_ phase: CatchSummary) -> UIView {
        let sprite = UIImageView(image: PokemonSprites.makeImage(pokemonName: phase.pokemonName, formId: phase.formId))
        sprite.contentMode = .scaleAspectFit
        sprite.layer.magnificationFilter = .nearest
        let nameLabel = UILabel(style: .body, weight: .semibold)
        nameLabel.text = PokemonSprites.makeTitle(pokemonName: phase.pokemonName, formName: phase.formName)
        let detailLabel = UILabel(style: .footnote, color: Color.textTertiary)
        detailLabel.text = phase.isFailed ? "Got away" : [phase.ballName, phase.formattedCaughtDate].compactMap { $0 }.joined(separator: " · ")
        let labels = UIStackView(arrangedSubviews: [nameLabel, detailLabel])
        labels.axis = .vertical
        let row = UIStackView(arrangedSubviews: [sprite, labels])
        row.spacing = Spacing.medium
        row.alignment = .center
        row.isAccessibilityElement = true
        row.accessibilityLabel = [nameLabel.text, detailLabel.text].compactMap { $0 }.joined(separator: ", ")
        NSLayoutConstraint.activate([
            sprite.widthAnchor.constraint(equalToConstant: 44),
            sprite.heightAnchor.constraint(equalToConstant: 44)
        ])
        return row
    }

    fileprivate func addRow(_ first: UIView, _ second: UIView) {
        let row = UIStackView(arrangedSubviews: [first, second])
        row.distribution = .fillEqually
        row.spacing = 10
        addReveal(row)
    }

    fileprivate func addReveal(_ content: UIView) {
        stack.addArrangedSubview(content)
        revealedViews.append(content)
        if !UIAccessibility.isReduceMotionEnabled {
            content.alpha = 0
            content.transform = CGAffineTransform(translationX: 0, y: 16)
        }
    }

    // MARK: Celebration

    fileprivate func celebrate() {
        UIAccessibility.post(notification: .announcement, argument: "Shiny \(report.caught.pokemonName) logged. \(makeCountText())")
        guard !UIAccessibility.isReduceMotionEnabled else {
            MilestoneCelebration.celebrate(sprite, in: view, isMajor: true)
            return
        }
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.55, initialSpringVelocity: 0, options: []) {
            self.sprite.alpha = 1
            self.sprite.transform = .identity
        } completion: { _ in
            MilestoneCelebration.celebrate(self.sprite, in: self.view, isMajor: true)
        }
        for (index, content) in revealedViews.enumerated() {
            UIView.animate(withDuration: 0.45, delay: 0.45 + Double(index) * CatchReportVC.revealStagger, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: []) {
                content.alpha = 1
                content.transform = .identity
            }
        }
    }

    // MARK: Actions

    @objc fileprivate func donePressed() {
        dismissSheet()
    }

    @objc fileprivate func detailsPressed() {
        guard let detail = CatchDetailTVC(container: container, catchId: report.caught.id) else { return }
        navigationController?.pushViewController(detail, animated: true)
    }

    // MARK: Formatting

    fileprivate static func formatOrdinal(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}
