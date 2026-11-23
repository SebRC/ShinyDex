import UIKit

final class CatchRateVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    fileprivate enum Section: Int, CaseIterable {
        case pokemon
        case conditions
        case situation
        case balls
    }

    fileprivate enum PokemonRow {
        case pokemon
        case form
        case game
    }

    fileprivate enum SituationRow {
        case turn
        case place
        case night
        case yourLevel
        case sameSpeciesOppositeGender
        case registeredAsCaught
    }

    fileprivate enum BallItem {
        case single(BallCatchRate)
        case noBonus([BallCatchRate])

        var rates: [BallCatchRate] {
            switch self {
            case .single(let rate): return [rate]
            case .noBonus(let rates): return rates
            }
        }

        var key: String {
            return rates.map { $0.ball }.joined(separator: ",")
        }
    }

    fileprivate static let levelRange = 1...100
    fileprivate static let turnRange = 1...30
    fileprivate static let defaultGame = Games.Scarlet

    fileprivate let container: AppContainer
    fileprivate let opensFromMenu: Bool
    fileprivate var number: Int?
    fileprivate var formId: String?
    fileprivate var game: Games
    fileprivate var situation = CatchSituation()
    fileprivate var sheet: CatchRateSheet?
    fileprivate var ballItems = [BallItem]()
    fileprivate var formChoices: FormChoices?
    fileprivate var areConditionsExpanded = true
    fileprivate var expandedBallKeys = Set<String>()

    fileprivate let tableView = UITableView(frame: .zero, style: .insetGrouped)
    fileprivate let resultView = CatchRateResultView()
    fileprivate let resultContainer = UIView()
    fileprivate let hpCell = CatchRateHPCell()
    fileprivate let statusCell = CatchRateSegmentCell(title: "Status", subtitle: CatchStatus.none.title, items: CatchStatus.allCases.compactMap { $0.makeImage() })
    fileprivate let levelCell = CatchRateStepperCell(title: "Level", range: CatchRateVC.levelRange)
    fileprivate let conditionsSummaryCell = CatchRateSummaryCell()
    fileprivate let turnCell = CatchRateStepperCell(title: "Turn", subtitle: "Quick Ball and Timer Ball", range: CatchRateVC.turnRange)
    fileprivate let placeCell = CatchRateSegmentCell(title: "Where", subtitle: "Dive Ball, Lure Ball and Dusk Ball", items: EncounterPlace.allCases.map { $0.title })
    fileprivate let nightCell = CatchRateSwitchCell(title: "Night", subtitle: "Dusk Ball")
    fileprivate let yourLevelCell = CatchRateStepperCell(title: "Your Pokémon's level", subtitle: "Level Ball", range: CatchRateVC.levelRange)
    fileprivate let genderCell = CatchRateSwitchCell(title: "Same species, opposite gender", subtitle: "Love Ball")
    fileprivate let registeredCell = CatchRateSwitchCell(title: "Caught before in this game", subtitle: "Repeat Ball")

    init(container: AppContainer, number: Int? = nil, formId: String? = nil, game: Games? = nil) {
        self.container = container
        self.number = number
        self.formId = formId
        opensFromMenu = number == nil
        self.game = game.flatMap { GetCatchRatesHandler.supportedGames.contains($0) ? $0 : nil } ?? CatchRateVC.defaultGame
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Catch Rate"
        navigationItem.largeTitleDisplayMode = opensFromMenu ? .always : .never
        view.backgroundColor = Color.background
        setUpLayout()
        connectControls()
        formChoices = number.flatMap { container.getPokemonForms.handle(GetPokemonFormsQuery(number: $0)) }
        recalculate(reloadingEverything: true)
    }

    fileprivate func setUpLayout() {
        tableView.backgroundColor = Color.background
        tableView.separatorColor = Color.separator
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 64
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(BallRateCell.self, forCellReuseIdentifier: BallRateCell.reuseIdentifier)
        tableView.register(CatchRateHeaderView.self, forHeaderFooterViewReuseIdentifier: CatchRateHeaderView.reuseIdentifier)
        resultContainer.backgroundColor = Color.background
        resultContainer.addAutoLayoutSubviews(resultView)
        resultView.pinEdges(to: resultContainer, insets: UIEdgeInsets(top: Spacing.small, left: Spacing.screenMargin, bottom: Spacing.small, right: Spacing.screenMargin))
        let stack = UIStackView(arrangedSubviews: [resultContainer, tableView])
        stack.axis = .vertical
        view.addAutoLayoutSubviews(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: Controls

    fileprivate func connectControls() {
        hpCell.onPercentChange = { [weak self] percent in
            self?.updateSituation {
                $0.hpPercent = percent
                $0.isAtOneHP = false
            }
        }
        hpCell.onPresetPicked = { [weak self] percent in
            Haptics.tap()
            self?.updateSituation { situation in
                situation.isAtOneHP = percent == nil
                situation.hpPercent = percent ?? situation.hpPercent
            }
        }
        statusCell.onChange = { [weak self] index in self?.updateSituation { $0.status = CatchStatus.allCases[index] } }
        levelCell.onChange = { [weak self] level in self?.updateSituation { $0.level = level } }
        levelCell.onValueTapped = { [weak self] in self?.promptNumber(for: self?.levelCell) { level in self?.updateSituation { $0.level = level } } }
        turnCell.onChange = { [weak self] turn in self?.updateSituation { $0.turn = turn } }
        turnCell.onValueTapped = { [weak self] in self?.promptNumber(for: self?.turnCell) { turn in self?.updateSituation { $0.turn = turn } } }
        placeCell.onChange = { [weak self] index in self?.updateSituation { $0.place = EncounterPlace.allCases[index] } }
        nightCell.onChange = { [weak self] isOn in self?.updateSituation { $0.isNight = isOn } }
        yourLevelCell.onChange = { [weak self] level in self?.updateSituation { $0.yourLevel = level } }
        yourLevelCell.onValueTapped = { [weak self] in self?.promptNumber(for: self?.yourLevelCell) { level in self?.updateSituation { $0.yourLevel = level } } }
        genderCell.onChange = { [weak self] isOn in self?.updateSituation { $0.isSameSpeciesOppositeGender = isOn } }
        registeredCell.onChange = { [weak self] isOn in self?.updateSituation { $0.isRegisteredAsCaught = isOn } }
    }

    fileprivate func updateSituation(_ change: (inout CatchSituation) -> Void) {
        change(&situation)
        recalculate(reloadingEverything: false)
    }

    fileprivate func promptNumber(for cell: CatchRateStepperCell?, onValue: @escaping (Int) -> Void) {
        guard let cell = cell else { return }
        let range = cell.range
        presentTextInput(title: cell.titleLabel.text ?? "",
                         message: "Enter a number from \(range.lowerBound) to \(range.upperBound).",
                         text: "\(cell.value)",
                         placeholder: "\(cell.value)",
                         keyboardType: .numberPad,
                         isValid: { Int($0).map { range.contains($0) } ?? false }) { value in
            Int(value).map(onValue)
        }
    }

    fileprivate func refreshControls() {
        hpCell.update(percent: situation.hpPercent, isAtOneHP: situation.isAtOneHP, currentHP: sheet?.currentHP, maxHP: sheet?.maxHP)
        statusCell.control.selectedSegmentIndex = CatchStatus.allCases.firstIndex(of: situation.status) ?? 0
        statusCell.subtitleLabel.text = situation.status.title
        levelCell.update(value: situation.level)
        turnCell.update(value: situation.turn)
        placeCell.control.selectedSegmentIndex = EncounterPlace.allCases.firstIndex(of: situation.place) ?? 0
        nightCell.toggle.isOn = situation.isNight
        yourLevelCell.update(value: situation.yourLevel)
        genderCell.toggle.isOn = situation.isSameSpeciesOppositeGender
        registeredCell.toggle.isOn = situation.isRegisteredAsCaught
        conditionsSummaryCell.label.text = makeConditionsSummary()
        conditionsSummaryCell.accessibilityLabel = "Conditions, \(makeConditionsSummary())"
    }

    fileprivate func makeConditionsSummary() -> String {
        let hp = situation.isAtOneHP ? "1 HP" : "\(situation.hpPercent)% HP"
        var parts = [hp, situation.status.title, "Level \(situation.level)"]
        if (situationRows.contains(.turn)) {
            parts.append("Turn \(situation.turn)")
        }
        if (situationRows.contains(.place)) {
            parts.append(situation.place.title)
        }
        if (situation.isNight && situationRows.contains(.night)) {
            parts.append("Night")
        }
        if (situation.isRegisteredAsCaught) {
            parts.append("Caught before")
        }
        return parts.joined(separator: " · ")
    }

    // MARK: Data

    fileprivate func recalculate(reloadingEverything: Bool) {
        let previousSituationRows = situationRows
        sheet = number.flatMap { container.getCatchRates.handle(GetCatchRatesQuery(number: $0, formId: formId, game: game, situation: situation)) }
        ballItems = makeBallItems(from: sheet?.rates ?? [])
        refreshControls()
        refreshResult()
        if (reloadingEverything || previousSituationRows != situationRows) {
            tableView.reloadData()
        }
        else {
            UIView.performWithoutAnimation {
                tableView.reloadSections(IndexSet([Section.pokemon.rawValue, Section.balls.rawValue]), with: .none)
                if (!areConditionsExpanded) {
                    tableView.reloadSections(IndexSet([Section.conditions.rawValue]), with: .none)
                }
            }
        }
    }

    fileprivate func makeBallItems(from rates: [BallCatchRate]) -> [BallItem] {
        let noBonusRates = rates.filter(CatchRateVC.hasNoBonus)
        var items = [BallItem]()
        for rate in rates {
            if (!CatchRateVC.hasNoBonus(rate)) {
                items.append(.single(rate))
            }
            else if (rate.ball == noBonusRates.first?.ball) {
                items.append(noBonusRates.count > 1 ? .noBonus(noBonusRates) : .single(rate))
            }
        }
        return items
    }

    fileprivate static func hasNoBonus(_ rate: BallCatchRate) -> Bool {
        return rate.bonus.multiplier == 1 && rate.bonus.catchRateChange == 0 && !rate.bonus.alwaysCatches
    }

    fileprivate var bestRate: BallCatchRate? {
        return sheet?.rates.first { !$0.bonus.alwaysCatches }
    }

    fileprivate func refreshResult() {
        if let best = bestRate {
            resultView.update(best: best)
        }
        resultContainer.isHidden = bestRate == nil
    }

    fileprivate var pokemonRows: [PokemonRow] {
        return [.pokemon] + (formChoices == nil ? [] : [.form]) + [.game]
    }

    fileprivate var conditionCells: [UITableViewCell] {
        guard sheet != nil else { return [] }
        return areConditionsExpanded ? [hpCell, statusCell, levelCell] : [conditionsSummaryCell]
    }

    fileprivate var situationRows: [SituationRow] {
        guard let balls = sheet.map({ Set($0.rates.map { $0.ball }) }) else { return [] }
        var rows = [SituationRow]()
        if (!balls.isDisjoint(with: ["quick", "timer"])) {
            rows.append(.turn)
        }
        if (!balls.isDisjoint(with: ["dive", "lure", "dusk"])) {
            rows.append(.place)
        }
        if (balls.contains("dusk")) {
            rows.append(.night)
        }
        if (balls.contains("level")) {
            rows.append(.yourLevel)
        }
        if (balls.contains("love")) {
            rows.append(.sameSpeciesOppositeGender)
        }
        if (balls.contains("repeat")) {
            rows.append(.registeredAsCaught)
        }
        return rows
    }

    fileprivate var shownSituationRows: [SituationRow] {
        return areConditionsExpanded ? situationRows : []
    }

    fileprivate func findCell(for row: SituationRow) -> UITableViewCell {
        switch row {
        case .turn: return turnCell
        case .place: return placeCell
        case .night: return nightCell
        case .yourLevel: return yourLevelCell
        case .sameSpeciesOppositeGender: return genderCell
        case .registeredAsCaught: return registeredCell
        }
    }

    fileprivate func toggleConditions() {
        areConditionsExpanded.toggle()
        Haptics.tap()
        tableView.reloadSections(IndexSet([Section.conditions.rawValue, Section.situation.rawValue]), with: .automatic)
    }

    fileprivate func showAssumptions() {
        let message = ["Max HP assumes average IVs.", "Critical captures aren't included, since they depend on how many Pokémon you've caught in that game."]
            .compactMap { $0 }.joined(separator: "\n\n")
        let alert = UIAlertController(title: "How this is worked out", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        alert.view.tintColor = Color.accent
        present(alert, animated: true)
    }

    // MARK: Table view

    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .pokemon: return pokemonRows.count
        case .conditions: return conditionCells.count
        case .situation: return shownSituationRows.count
        case .balls: return ballItems.count
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard sheet != nil else { return nil }
        switch Section(rawValue: section)! {
        case .pokemon:
            return nil
        case .conditions:
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: CatchRateHeaderView.reuseIdentifier) as! CatchRateHeaderView
            header.configure(title: "Conditions", actionTitle: areConditionsExpanded ? "Hide" : "Edit") { [weak self] in self?.toggleConditions() }
            return header
        case .situation:
            return shownSituationRows.isEmpty ? nil : SectionHeaderView.make(for: tableView, title: "Situation")
        case .balls:
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: CatchRateHeaderView.reuseIdentifier) as! CatchRateHeaderView
            header.configure(title: "Chance per throw", actionTitle: nil, symbolName: "info.circle", actionLabel: "How this is worked out") { [weak self] in self?.showAssumptions() }
            return header
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.tableView(tableView, viewForHeaderInSection: section) == nil ? Spacing.small : UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 52
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return self.tableView(tableView, titleForFooterInSection: section) == nil ? Spacing.extraSmall : UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return Section(rawValue: section) == .pokemon && sheet == nil ? "Choose a Pokémon to see the chance of catching it with each ball." : nil
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section(rawValue: indexPath.section)! {
        case .pokemon:
            return makePokemonCell(for: pokemonRows[indexPath.row])
        case .conditions:
            return conditionCells[indexPath.row]
        case .situation:
            return findCell(for: shownSituationRows[indexPath.row])
        case .balls:
            let cell = tableView.dequeueReusableCell(withIdentifier: BallRateCell.reuseIdentifier, for: indexPath) as! BallRateCell
            let item = ballItems[indexPath.row]
            let isBest = item.rates.contains { $0.ball == bestRate?.ball }
            cell.configure(rates: item.rates, isBest: isBest, isExpanded: expandedBallKeys.contains(item.key))
            return cell
        }
    }

    fileprivate func makePokemonCell(for row: PokemonRow) -> UITableViewCell {
        let cell = UITableViewCell(style: row == .pokemon && sheet != nil ? .subtitle : .value1, reuseIdentifier: nil)
        cell.backgroundColor = Color.surface
        let selectedBackground = UIView()
        selectedBackground.backgroundColor = Color.surfaceRaised
        cell.selectedBackgroundView = selectedBackground
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.textColor = Color.textPrimary
        cell.detailTextLabel?.textColor = Color.textTertiary
        switch row {
        case .pokemon:
            if let sheet = sheet {
                cell.textLabel?.text = sheet.pokemonName
                cell.textLabel?.font = UIFont.make(.body, weight: .semibold)
                cell.detailTextLabel?.text = "Catch rate \(sheet.catchRate) · \(sheet.types.map { $0.capitalizingFirstLetter() }.joined(separator: "/"))"
                cell.detailTextLabel?.font = UIFont.make(.footnote)
                cell.imageView?.image = PokemonSprites.makeImage(pokemonName: sheet.pokemonName, formId: sheet.formId)?.resized(to: CGSize(width: 44, height: 44))
                cell.imageView?.layer.magnificationFilter = .nearest
            }
            else {
                cell.textLabel?.text = "Choose a Pokémon"
                cell.textLabel?.textColor = Color.accent
            }
        case .form:
            cell.textLabel?.text = "Form"
            cell.detailTextLabel?.text = formChoices?.findName(of: formId)
        case .game:
            cell.textLabel?.text = "Game"
            cell.detailTextLabel?.text = game.displayName
        }
        return cell
    }

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        switch Section(rawValue: indexPath.section)! {
        case .pokemon, .balls: return true
        case .conditions: return !areConditionsExpanded
        case .situation: return false
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch Section(rawValue: indexPath.section)! {
        case .pokemon:
            switch pokemonRows[indexPath.row] {
            case .pokemon: showPokemonPicker()
            case .form: showFormPicker()
            case .game: showGamePicker()
            }
        case .conditions:
            toggleConditions()
        case .balls:
            let key = ballItems[indexPath.row].key
            if (expandedBallKeys.remove(key) == nil) {
                expandedBallKeys.insert(key)
            }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        case .situation:
            break
        }
    }

    // MARK: Pickers

    fileprivate func showPokemonPicker() {
        let picker = PokemonPickerModalVC(container: container, configuration: .catchRate) { [weak self] _, picked in
            guard let self = self, let pokemon = picked.first else { return }
            self.number = pokemon.number
            self.formId = nil
            self.formChoices = self.container.getPokemonForms.handle(GetPokemonFormsQuery(number: pokemon.number))
            self.recalculate(reloadingEverything: true)
        }
        present(picker.wrapInSheet(), animated: true)
    }

    fileprivate func showFormPicker() {
        guard let choices = formChoices else { return }
        let picker = FormPicker.make(pokemonName: sheet?.pokemonName, choices: choices, selectedFormId: formId) { [weak self] formId in
            self?.formId = formId
            self?.recalculate(reloadingEverything: true)
        }
        navigationController?.pushViewController(picker, animated: true)
    }

    fileprivate func showGamePicker() {
        let supported = Set(GetCatchRatesHandler.supportedGames)
        let choices = container.getGameChoices.handle(GetGameChoicesQuery(number: number)).filter { supported.contains($0.game) }
        let picker = GameSelector.make(choices: choices, selectedGame: game, pokemonName: sheet?.pokemonName, caption: "Catching in") { [weak self] game in
            self?.game = game
            self?.recalculate(reloadingEverything: true)
        }
        navigationController?.pushViewController(picker, animated: true)
    }
}
