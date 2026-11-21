import UIKit

class LocationsTVC: UITableViewController {
    fileprivate enum Row {
        case game
        case hunt
        case relatedPokemon(NamedPokemon)
        case encounter(PokemonLocationsResult.Encounter)
        case serebii
    }

    fileprivate struct Section {
        let title: String?
        let footer: String?
        let rows: [Row]
    }

    fileprivate let container: AppContainer
    fileprivate let number: Int
    fileprivate let game: Games
    fileprivate let onHuntGameChanged: () -> Void
    fileprivate var result: PokemonLocationsResult?
    fileprivate var huntingGame: Games?
    fileprivate var sections = [Section]()

    init(container: AppContainer, number: Int, game: Games, onHuntGameChanged: @escaping () -> Void = {}) {
        self.container = container
        self.number = number
        self.game = game
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
        tableView.estimatedRowHeight = 60
        reload()
    }

    fileprivate func reload() {
        result = container.getPokemonLocations.handle(GetPokemonLocationsQuery(number: number, game: game))
        huntingGame = container.getPokemonDetails.handle(GetPokemonDetailsQuery(number: number))?.settings.game
        title = result.map { "\($0.pokemonName) in \(game.displayName)" } ?? "Locations"
        sections = makeSections()
        navigationItem.rightBarButtonItem = result.map(LocationsTVC.makeTechniqueExplanations).flatMap { $0.isEmpty ? nil : makeInfoButton() }
        tableView.reloadData()
    }

    fileprivate func makeSections() -> [Section] {
        guard let result = result else { return [] }
        var gameRows: [Row] = [.game]
        if result.availability == .catchable {
            gameRows.append(.hunt)
        }
        switch result.guidance {
        case .evolveFrom(let pokemon), .breedFrom(let pokemon):
            gameRows.append(.relatedPokemon(pokemon))
        default:
            break
        }
        var sections = [Section(title: nil, footer: LocationsTVC.makeSummary(for: result), rows: gameRows)]
        sections += result.places.map { place in
            Section(title: place.area, footer: nil, rows: place.encounters.map { .encounter($0) })
        }
        sections.append(Section(title: nil, footer: nil, rows: [.serebii]))
        return sections
    }

    fileprivate func makeInfoButton() -> UIBarButtonItem {
        let button = UIBarButtonItem(image: UIImage(systemName: "info.circle"), style: .plain, target: self, action: #selector(infoPressed))
        button.accessibilityLabel = "How lead techniques work"
        return button
    }

    @objc fileprivate func infoPressed() {
        guard let result = result else { return }
        present(TechniquesInfoTVC(explanations: LocationsTVC.makeTechniqueExplanations(for: result)).wrapInSheet(), animated: true)
    }

    fileprivate static func makeSummary(for result: PokemonLocationsResult) -> String? {
        let name = result.pokemonName
        let game = result.game.displayName
        var lines = [String]()
        if !result.hasLocationData {
            lines.append("There's no location data for \(game) yet. Serebii below may help.")
        }
        else if result.places.isEmpty {
            switch result.guidance {
            case .evolveFrom(let pokemon):
                lines.append("\(name) isn't found directly in \(game). Evolve it from \(pokemon.name).")
            case .breedFrom(let pokemon):
                lines.append("\(name) isn't found directly in \(game). Breed it from \(pokemon.name).")
            case .tradeOnly:
                lines.append("\(name) can't be caught in \(game). It has to be traded in, or evolved by trading.")
            case .shinyLocked:
                lines.append("\(name) only comes from shiny locked encounters in \(game), so it can't be shiny hunted here.")
            case .unavailable:
                lines.append("\(name) isn't in \(game).")
            case .none:
                lines.append("No locations found for \(name) in \(game).")
            }
        }
        let encounters = result.places.flatMap { $0.encounters }
        if !encounters.isEmpty && encounters.allSatisfy({ $0.isShinyLocked }) {
            lines.append("Every encounter listed for \(name) in \(game) is shiny locked, so it can't be shiny hunted here.")
        }
        else if encounters.contains(where: { $0.isShinyLocked }) {
            lines.append("Shiny locked encounters can never be shiny, so they're listed last and can't be hunted.")
        }
        if !makeTechniqueExplanations(for: result).isEmpty {
            lines.append("Tap ⓘ to see how each lead technique works.")
        }
        if result.hasLocationData && result.isApproximate {
            lines.append("Location data for \(game) is incomplete, so some places may be missing.")
        }
        return lines.isEmpty ? nil : lines.joined(separator: "\n\n")
    }

    fileprivate static func makeTechniqueExplanations(for result: PokemonLocationsResult) -> [TechniquesInfoTVC.Explanation] {
        let encounters = result.places.flatMap { $0.encounters }.filter { !$0.isShinyLocked }
        var explanations = [TechniquesInfoTVC.Explanation]()
        if encounters.contains(where: { $0.repelTrick != nil }) {
            explanations.append(TechniquesInfoTVC.Explanation(title: "Repel trick",
                body: "Lead with a Pokémon at the level shown and use a Repel, so weaker Pokémon don't appear. The Repel also stops most encounters, so you'll walk further between them. The share that still happens is shown with each rate."))
        }
        if encounters.contains(where: { $0.repelTrick?.withPressureRatePercent != nil }) {
            explanations.append(TechniquesInfoTVC.Explanation(title: "Pressure, Hustle or Vital Spirit",
                body: "A lead with one of these makes wild Pokémon appear at higher levels, so more of them get past the Repel."))
        }
        if let speedAbilities = describeEncounterSpeedAbilities(in: result.game), encounters.contains(where: { $0.isSpedUpByAbilities }) {
            explanations.append(TechniquesInfoTVC.Explanation(title: speedAbilities,
                body: "A lead with one of these makes wild Pokémon appear twice as often, without changing which ones. It works with the Repel trick too, winning back some of the encounters it stops."))
        }
        if encounters.contains(where: { !$0.abilityBoosts.isEmpty }) {
            explanations.append(TechniquesInfoTVC.Explanation(title: "Static and Magnet Pull",
                body: "Lead with a Pokémon that has the ability to make Electric or Steel types more likely."))
        }
        if encounters.contains(where: { $0.keenEyeBoost != nil }) {
            explanations.append(TechniquesInfoTVC.Explanation(title: "Keen Eye and Intimidate",
                body: "A lead at the level shown halves encounters with Pokémon 5 or more levels below it."))
        }
        return explanations
    }

    fileprivate static func describeEncounterSpeedAbilities(in game: Games) -> String? {
        if [.Ruby, .Sapphire, .FireRed, .LeafGreen].contains(game) {
            return "Illuminate"
        }
        switch GamesList.games[game]?.generation ?? 0 {
        case 3...4: return "Illuminate or Arena Trap"
        case 5...8: return "Illuminate, Arena Trap or No Guard"
        default: return nil
        }
    }

    // MARK: Table

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch sections[indexPath.section].rows[indexPath.row] {
        case .game, .relatedPokemon: return 68
        case .hunt: return UITableView.automaticDimension
        default: return UITableView.automaticDimension
        }
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return SectionHeaderView.make(for: tableView, title: sections[section].title)
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return sections[section].footer
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch sections[indexPath.section].rows[indexPath.row] {
        case .game:
            let cell = makeCell(style: .value1, isTappable: false)
            cell.textLabel?.text = "Game"
            cell.detailTextLabel?.text = game.displayName
            cell.imageView?.image = GamesList.games[game].flatMap { PixelArt.makeCenteredImage(named: $0.coverPokemon) }?.padded(to: CGSize(width: 52, height: 52)).withRenderingMode(.alwaysOriginal)
            return cell
        case .hunt:
            let isHuntingGame = huntingGame == game
            let cell = makeCell(style: .default, isTappable: !isHuntingGame)
            cell.accessoryType = .none
            cell.textLabel?.text = isHuntingGame ? "Hunting in \(game.displayName)" : "Hunt in \(game.displayName)"
            cell.textLabel?.textColor = isHuntingGame ? Color.textTertiary : Color.accent
            cell.imageView?.image = UIImage.makeSymbol(isHuntingGame ? "checkmark.circle" : "scope", pointSize: 18, weight: .semibold)
            cell.imageView?.tintColor = isHuntingGame ? Color.textTertiary : Color.accent
            cell.accessibilityTraits = isHuntingGame ? .staticText : .button
            return cell
        case .relatedPokemon(let pokemon):
            let cell = makeCell(style: .default, isTappable: true)
            cell.textLabel?.text = "Where to find \(pokemon.name)"
            cell.textLabel?.textColor = Color.accent
            cell.imageView?.image = PokemonSprites.makeImage(pokemonName: pokemon.name)?.padded(to: CGSize(width: 52, height: 52)).withRenderingMode(.alwaysOriginal)
            return cell
        case .encounter(let encounter):
            let cell = makeCell(style: .subtitle, isTappable: false)
            cell.textLabel?.text = encounter.method
            cell.textLabel?.textColor = encounter.isShinyLocked ? Color.textTertiary : Color.textPrimary
            cell.detailTextLabel?.attributedText = LocationsTVC.makeDetails(for: encounter)
            cell.detailTextLabel?.numberOfLines = 0
            return cell
        case .serebii:
            let cell = makeCell(style: .default, isTappable: true)
            cell.textLabel?.text = "View on Serebii"
            cell.imageView?.image = UIImage(systemName: "safari")
            cell.imageView?.tintColor = Color.accent
            return cell
        }
    }

    fileprivate func makeCell(style: UITableViewCell.CellStyle, isTappable: Bool) -> UITableViewCell {
        let cell = UITableViewCell(style: style, reuseIdentifier: nil)
        cell.backgroundColor = Color.surface
        let selectedBackground = UIView()
        selectedBackground.backgroundColor = Color.surfaceRaised
        cell.selectedBackgroundView = selectedBackground
        cell.textLabel?.font = UIFont.make(.body, weight: .semibold)
        cell.textLabel?.textColor = Color.textPrimary
        cell.detailTextLabel?.font = UIFont.make(.subheadline)
        cell.detailTextLabel?.textColor = Color.textTertiary
        cell.selectionStyle = isTappable ? .default : .none
        cell.accessoryType = isTappable ? .disclosureIndicator : .none
        return cell
    }

    fileprivate static func makeDetails(for encounter: PokemonLocationsResult.Encounter) -> NSAttributedString {
        let levels: String?
        if encounter.maximumLevel == 0 {
            levels = nil
        }
        else {
            levels = encounter.minimumLevel == encounter.maximumLevel ? "Lv. \(encounter.minimumLevel)" : "Lv. \(encounter.minimumLevel)–\(encounter.maximumLevel)"
        }
        let rate = encounter.isOneTime ? nil : "\(encounter.ratePercent)%"
        let details = NSMutableAttributedString(string: [levels, rate, encounter.condition].compactMap { $0 }.joined(separator: " · "),
                                                attributes: [.font: UIFont.make(.subheadline), .foregroundColor: Color.textTertiary])
        if encounter.isShinyLocked {
            let lock = NSTextAttachment(image: UIImage.makeSymbol("lock.fill", pointSize: 12, weight: .semibold)!.withTintColor(Color.danger, renderingMode: .alwaysOriginal))
            let lockLine = NSMutableAttributedString(string: "\n")
            lockLine.append(NSAttributedString(attachment: lock))
            lockLine.append(NSAttributedString(string: " Shiny locked", attributes: [.font: UIFont.make(.subheadline, weight: .semibold), .foregroundColor: Color.danger]))
            details.append(lockLine)
            return details
        }
        var boosts = [String]()
        if let repel = encounter.repelTrick {
            boosts.append("Repel trick with a Lv. \(repel.leadLevel) lead: \(repel.ratePercent)%" + describeEncounterSpeed(repel.encounterPercent))
            if let withPressure = repel.withPressureRatePercent {
                boosts.append("Repel with a Lv. \(repel.leadLevel) Pressure lead: \(withPressure)%" + describeEncounterSpeed(repel.withPressureEncounterPercent))
            }
        }
        if let keenEye = encounter.keenEyeBoost {
            boosts.append("Keen Eye or Intimidate Lv. \(keenEye.leadLevel) lead: \(keenEye.ratePercent)%")
        }
        for boost in encounter.abilityBoosts {
            boosts.append("\(boost.ability == .staticAbility ? "Static" : "Magnet Pull") lead: \(boost.ratePercent)%")
        }
        for boost in boosts {
            details.append(NSAttributedString(string: "\n" + boost, attributes: [.font: UIFont.make(.subheadline, weight: .semibold), .foregroundColor: Color.accent]))
        }
        return details
    }

    fileprivate static func describeEncounterSpeed(_ encounterPercent: Int?) -> String {
        guard let encounterPercent = encounterPercent, encounterPercent < 100 else { return "" }
        return ", encounters \(encounterPercent)% as often"
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch sections[indexPath.section].rows[indexPath.row] {
        case .hunt:
            huntInGame()
        case .relatedPokemon(let pokemon):
            navigationController?.pushViewController(LocationsTVC(container: container, number: pokemon.number, game: game), animated: true)
        case .serebii:
            guard let url = container.getLocationLink.handle(GetLocationLinkQuery(number: number)) else { return }
            navigationController?.pushViewController(LocationVC(url: url), animated: true)
        case .game, .encounter:
            break
        }
    }

    fileprivate func huntInGame() {
        guard huntingGame != game, let pokemon = container.getPokemonDetails.handle(GetPokemonDetailsQuery(number: number)) else { return }
        let preview = container.previewHuntSettings.handle(PreviewHuntSettingsQuery(settings: pokemon.settings, chain: pokemon.chain, selectingGame: game))
        container.saveHuntSettings.handle(SaveHuntSettingsCommand(number: number, settings: preview.settings))
        Haptics.tap()
        onHuntGameChanged()
        reload()
    }
}
