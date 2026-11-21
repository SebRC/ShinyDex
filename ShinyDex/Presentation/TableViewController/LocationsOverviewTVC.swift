import UIKit

class LocationsOverviewTVC: UITableViewController {
    fileprivate struct Section {
        let title: String
        let footer: String?
        let games: [LocationsOverview.GameSummary]
    }

    fileprivate static let bestGameCount = 3

    fileprivate let container: AppContainer
    fileprivate let number: Int
    fileprivate let onHuntGameChanged: () -> Void
    fileprivate var overview: LocationsOverview?
    fileprivate var sections = [Section]()

    init(container: AppContainer, number: Int, onHuntGameChanged: @escaping () -> Void = {}) {
        self.container = container
        self.number = number
        self.onHuntGameChanged = onHuntGameChanged
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        tableView.backgroundColor = Color.background
        tableView.separatorColor = Color.separator
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 72
        tableView.register(GameLocationCell.self, forCellReuseIdentifier: GameLocationCell.reuseIdentifier)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reload()
    }

    fileprivate func reload() {
        overview = container.getLocationsOverview.handle(GetLocationsOverviewQuery(number: number))
        title = overview.map { "Where to find \($0.pokemonName)" } ?? "Locations"
        sections = makeSections()
        tableView.reloadData()
    }

    fileprivate func makeSections() -> [Section] {
        guard let overview = overview else { return [] }
        var sections = [Section]()
        let bestGames = Array(overview.bestGames.prefix(LocationsOverviewTVC.bestGameCount))
        if !bestGames.isEmpty {
            sections.append(Section(title: "Best odds", footer: "Rates are per encounter, with the lead technique that helps most.", games: bestGames))
        }
        let generations = Dictionary(grouping: overview.games) { $0.generation }
        for generation in generations.keys.sorted() {
            sections.append(Section(title: "Generation \(generation)", footer: nil, games: generations[generation] ?? []))
        }
        return sections
    }

    // MARK: Table

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].games.count
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return SectionHeaderView.make(for: tableView, title: sections[section].title)
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return sections[section].footer
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GameLocationCell.reuseIdentifier, for: indexPath) as! GameLocationCell
        let summary = sections[indexPath.section].games[indexPath.row]
        cell.configure(summary: summary, isHuntingGame: summary.game == overview?.huntingGame)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let game = sections[indexPath.section].games[indexPath.row].game
        let locations = LocationsTVC(container: container, number: number, game: game) { [weak self] in
            self?.onHuntGameChanged()
        }
        navigationController?.pushViewController(locations, animated: true)
    }
}

fileprivate class GameLocationCell: UITableViewCell {
    static let reuseIdentifier = "gameLocationCell"
    fileprivate static let iconSize: CGFloat = 44

    fileprivate let iconImageView = UIImageView()
    fileprivate let gameLabel = UILabel(style: .body, weight: .semibold, color: Color.textPrimary)
    fileprivate let huntingLabel = UILabel(style: .caption2, weight: .bold, color: Color.accent)
    fileprivate let verdictLabel = UILabel(style: .subheadline, color: Color.textTertiary, lines: 0)
    fileprivate let techniqueLabel = UILabel(style: .subheadline, weight: .semibold, color: Color.accent, lines: 0)
    fileprivate let rateLabel = UILabel(style: .title3, weight: .bold, color: Color.textPrimary)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = Color.surface
        let selectedBackground = UIView()
        selectedBackground.backgroundColor = Color.surfaceRaised
        selectedBackgroundView = selectedBackground
        accessoryType = .disclosureIndicator

        iconImageView.contentMode = .scaleAspectFit
        iconImageView.layer.magnificationFilter = .nearest
        huntingLabel.backgroundColor = Color.accentSubtle
        huntingLabel.textAlignment = .center
        huntingLabel.layer.cornerRadius = CornerRadius.tiny
        huntingLabel.layer.masksToBounds = true
        huntingLabel.setContentHuggingPriority(.required, for: .horizontal)
        huntingLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        rateLabel.font = UIFont.make(.title3, weight: .bold, monospacedDigits: true)
        rateLabel.setContentHuggingPriority(.required, for: .horizontal)
        rateLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        let titleRow = UIStackView(arrangedSubviews: [gameLabel, huntingLabel, UIView()])
        titleRow.spacing = Spacing.small
        titleRow.alignment = .center
        let labels = UIStackView(arrangedSubviews: [titleRow, verdictLabel, techniqueLabel])
        labels.axis = .vertical
        labels.spacing = 2
        let row = UIStackView(arrangedSubviews: [iconImageView, labels, rateLabel])
        row.spacing = Spacing.medium
        row.alignment = .center
        contentView.addAutoLayoutSubviews(row)
        row.pinEdges(to: contentView, insets: UIEdgeInsets(top: Spacing.medium, left: Spacing.large, bottom: Spacing.medium, right: Spacing.small))
        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: GameLocationCell.iconSize),
            iconImageView.heightAnchor.constraint(equalToConstant: GameLocationCell.iconSize)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(summary: LocationsOverview.GameSummary, isHuntingGame: Bool) {
        iconImageView.image = GamesList.games[summary.game].flatMap { PixelArt.makeCenteredImage(named: $0.coverPokemon) }
        gameLabel.text = summary.game.displayName
        huntingLabel.text = isHuntingGame ? " HUNTING " : nil
        huntingLabel.isHidden = !isHuntingGame
        let isHuntable = summary.availability == .catchable && summary.bestPlace != nil
        iconImageView.alpha = isHuntable ? 1 : 0.45
        gameLabel.textColor = isHuntable ? Color.textPrimary : Color.textSecondary
        verdictLabel.attributedText = GameLocationCell.makeVerdict(for: summary)
        if let place = summary.bestPlace, summary.availability == .catchable {
            rateLabel.text = place.isOneTime ? nil : "\(place.ratePercent)%"
            techniqueLabel.text = place.technique.map(GameLocationCell.describe)
        }
        else {
            rateLabel.text = nil
            techniqueLabel.text = nil
        }
        rateLabel.isHidden = rateLabel.text == nil
        techniqueLabel.isHidden = techniqueLabel.text == nil
    }

    fileprivate static func makeVerdict(for summary: LocationsOverview.GameSummary) -> NSAttributedString {
        let plain: [NSAttributedString.Key: Any] = [.font: UIFont.make(.subheadline), .foregroundColor: Color.textTertiary]
        if summary.availability == .shinyLocked || summary.guidance == .shinyLocked {
            let warning: [NSAttributedString.Key: Any] = [.font: UIFont.make(.subheadline, weight: .semibold), .foregroundColor: Color.danger]
            let text = NSMutableAttributedString(attachment: NSTextAttachment(image: UIImage.makeSymbol("lock.fill", pointSize: 12, weight: .semibold)!.withTintColor(Color.danger, renderingMode: .alwaysOriginal)))
            text.append(NSAttributedString(string: " Shiny locked", attributes: warning))
            return text
        }
        return NSAttributedString(string: describeVerdict(for: summary), attributes: plain)
    }

    fileprivate static func describeVerdict(for summary: LocationsOverview.GameSummary) -> String {
        if let place = summary.bestPlace, summary.availability == .catchable {
            let approximation = summary.isApproximate ? "≈ " : ""
            return place.isOneTime ? "\(approximation)\(place.method) at \(place.area), once" : "\(approximation)\(place.area) · \(place.method)"
        }
        switch summary.guidance {
        case .evolveFrom(let pokemon):
            return "Evolve from \(pokemon.name)"
        case .breedFrom(let pokemon):
            return "Breed from \(pokemon.name)"
        case .tradeOnly:
            return "Trade only"
        case .unavailable:
            return "Not in this game"
        case .shinyLocked, .none:
            break
        }
        if summary.availability == .tradeOnly {
            return "Trade only"
        }
        return summary.hasLocationData ? "No locations found" : "No location data yet"
    }

    fileprivate static func describe(_ technique: LocationsOverview.Technique) -> String {
        let description = "\(technique.ratePercent)% \(describe(technique.kind))"
        guard let encounterPercent = technique.encounterPercent, encounterPercent < 100 else { return description }
        return "\(description), encounters \(encounterPercent)% as often"
    }

    fileprivate static func describe(_ technique: LocationsOverview.Technique.Kind) -> String {
        switch technique {
        case .repel: return "with the Repel trick"
        case .repelWithPressure: return "with Repel and a Pressure lead"
        case .keenEye: return "with a Keen Eye lead"
        case .staticAbility: return "with a Static lead"
        case .magnetPull: return "with a Magnet Pull lead"
        }
    }
}
