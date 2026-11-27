import UIKit

class JourneyDetailTVC: UITableViewController {
    fileprivate enum Mode: Int, CaseIterable {
        case pokemon, timeline

        var title: String {
            switch self {
            case .pokemon: return "Pokémon"
            case .timeline: return "Timeline"
            }
        }
    }

    fileprivate let container: AppContainer
    fileprivate let journeyId: JourneyID
    fileprivate var journey: JourneyDetails
    fileprivate var timeline: [JourneyTimelineStep] {
        return journey.timeline
    }
    fileprivate enum PokemonRow {
        case entry(JourneyEntryDetails)
        case phase(CatchSummary, of: JourneyEntryDetails)
    }

    fileprivate let header = JourneyHeaderView()
    fileprivate var mode = Mode.pokemon
    fileprivate var expandedEntryIds = Set<JourneyEntryID>()
    fileprivate var isReordering = false

    fileprivate var pokemonRows: [PokemonRow] {
        return journey.entries.flatMap { entry -> [PokemonRow] in
            let phaseRows = expandedEntryIds.contains(entry.id) ? entry.phases.map { PokemonRow.phase($0, of: entry) } : []
            return [.entry(entry)] + phaseRows
        }
    }

    init?(container: AppContainer, journeyId: JourneyID) {
        guard let journey = container.getJourneyDetails.handle(GetJourneyDetailsQuery(journeyId: journeyId)) else { return nil }
        self.container = container
        self.journeyId = journeyId
        self.journey = journey
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPressed))
        addButton.accessibilityLabel = "Add Pokémon"
        let moreButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"), style: .plain, target: self, action: #selector(morePressed))
        moreButton.accessibilityLabel = "More"
        navigationItem.rightBarButtonItems = [moreButton, addButton]

        tableView.backgroundColor = Color.background
        tableView.separatorColor = Color.separator
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 72
        tableView.register(JourneyEntryCell.self, forCellReuseIdentifier: JourneyEntryCell.reuseIdentifier)
        tableView.register(TimelineCell.self, forCellReuseIdentifier: TimelineCell.reuseIdentifier)
        tableView.register(PhaseCell.self, forCellReuseIdentifier: PhaseCell.reuseIdentifier)
        header.onModeChange = { [weak self] index in
            self?.mode = Mode(rawValue: index) ?? .pokemon
            self?.setEditing(false, animated: false)
            self?.reload()
        }
        header.modeTitles = Mode.allCases.map { $0.title }
        tableView.tableHeaderView = header
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reload()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let width = tableView.bounds.width
        let height = header.systemLayoutSizeFitting(CGSize(width: width, height: 0), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel).height
        if (header.frame.height != height || header.frame.width != width) {
            header.frame = CGRect(x: 0, y: 0, width: width, height: height)
            tableView.tableHeaderView = header
        }
    }

    fileprivate func refreshJourney() {
        if let updated = container.getJourneyDetails.handle(GetJourneyDetailsQuery(journeyId: journeyId)) {
            journey = updated
        }
    }

    fileprivate func getLinkableCatches(for entry: JourneyEntryDetails) -> [CatchSummary] {
        return container.getLinkableCatches.handle(GetLinkableCatchesQuery(journeyId: journeyId, entryId: entry.id))
    }

    fileprivate func reload() {
        refreshJourney()
        title = journey.name
        header.configure(caught: journey.caughtCount, total: journey.entries.count, phases: journey.phaseCount, firstCatch: timeline.first { !$0.isPhase }?.caught.caughtDate)
        header.configure(tally: journey.tally)
        tableView.reloadData()
        updateEmptyState()
    }

    fileprivate func updateEmptyState() {
        switch mode {
        case .pokemon where journey.entries.isEmpty:
            tableView.backgroundView = EmptyStateView(symbolName: "plus.circle", title: "No Pokémon yet", message: "Tap + to add the Pokémon this journey is about.")
        case .timeline where timeline.isEmpty:
            tableView.backgroundView = EmptyStateView(symbolName: "calendar", title: "Nothing caught yet", message: "Link a catch or log a phase for a Pokémon in this journey and it shows up here, in the order you found them.")
        default:
            tableView.backgroundView = nil
        }
        tableView.backgroundView?.isUserInteractionEnabled = false
    }

    // MARK: Table

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mode == .pokemon ? pokemonRows.count : timeline.count
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard mode == .pokemon, !journey.entries.isEmpty else { return nil }
        return "Adding a Pokémon you've already caught doesn't tick it off. Tap it to link the catch you made for this journey, or to log phases you found along the way."
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch mode {
        case .pokemon:
            switch pokemonRows[indexPath.row] {
            case .entry(let entry):
                let cell = tableView.dequeueReusableCell(withIdentifier: JourneyEntryCell.reuseIdentifier, for: indexPath) as! JourneyEntryCell
                cell.configure(entry: entry, phasesExpanded: expandedEntryIds.contains(entry.id))
                cell.onPhasesTapped = { [weak self] in self?.togglePhases(of: entry) }
                return cell
            case .phase(let phase, _):
                let cell = tableView.dequeueReusableCell(withIdentifier: PhaseCell.reuseIdentifier, for: indexPath) as! PhaseCell
                cell.configure(phase: phase)
                return cell
            }
        case .timeline:
            let cell = tableView.dequeueReusableCell(withIdentifier: TimelineCell.reuseIdentifier, for: indexPath) as! TimelineCell
            let step = timeline[indexPath.row]
            let previousDate = indexPath.row > 0 ? timeline[indexPath.row - 1].caught.caughtDate : nil
            let catchNumber = step.isPhase ? nil : timeline[...indexPath.row].filter { !$0.isPhase }.count
            cell.configure(catchNumber: catchNumber,
                           step: step,
                           previousDate: previousDate,
                           isFirst: indexPath.row == 0,
                           isLast: indexPath.row == timeline.count - 1)
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch mode {
        case .pokemon:
            switch pokemonRows[indexPath.row] {
            case .entry(let entry): showActions(for: entry, at: indexPath)
            case .phase(let phase, _): showCatch(phase)
            }
        case .timeline:
            showCatch(timeline[indexPath.row].caught)
        }
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return mode == .pokemon
    }

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return mode == .pokemon && isReordering
    }

    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        container.updateJourney.handle(UpdateJourneyCommand(journeyId: journeyId, change: .moveEntry(from: sourceIndexPath.row, to: destinationIndexPath.row)))
        refreshJourney()
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard mode == .pokemon else { return nil }
        switch pokemonRows[indexPath.row] {
        case .entry(let entry):
            let remove = UIContextualAction(style: .destructive, title: "Remove") { [weak self] _, _, done in
                self?.remove(entry)
                done(false)
            }
            return UISwipeActionsConfiguration(actions: [remove])
        case .phase(let phase, let entry):
            let unlink = UIContextualAction(style: .destructive, title: "Unlink") { [weak self] _, _, done in
                self?.unlinkPhase(phase, from: entry)
                done(true)
            }
            return UISwipeActionsConfiguration(actions: [unlink])
        }
    }

    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard mode == .pokemon, case .entry(let entry) = pokemonRows[indexPath.row] else { return nil }
        guard entry.linkedCatch == nil, entry.linkableCatchCount > 0 else { return nil }
        let link = UIContextualAction(style: .normal, title: "Link catch") { [weak self] _, _, done in
            self?.pickCatch(for: entry)
            done(true)
        }
        link.backgroundColor = Color.accent
        return UISwipeActionsConfiguration(actions: [link])
    }

    // MARK: Entry actions

    fileprivate func showActions(for entry: JourneyEntryDetails, at indexPath: IndexPath) {
        let name = entry.pokemonName ?? "this Pokémon"
        let linked = entry.linkedCatch
        let linkable = getLinkableCatches(for: entry)
        let message = linked == nil && linkable.isEmpty ? "You haven't caught a shiny \(name) yet. Log one from its tracker, then link it here." : nil
        let sheet = UIAlertController(title: name, message: message, preferredStyle: .actionSheet)
        if let linked = linked {
            sheet.addAction(UIAlertAction(title: "View catch", style: .default) { [weak self] _ in self?.showCatch(linked) })
            if (linkable.count > 1) {
                sheet.addAction(UIAlertAction(title: "Link a different catch", style: .default) { [weak self] _ in self?.pickCatch(for: entry) })
            }
            sheet.addAction(UIAlertAction(title: "Unlink catch", style: .default) { [weak self] _ in self?.link(nil, to: entry) })
        }
        else if (!linkable.isEmpty) {
            sheet.addAction(UIAlertAction(title: "Link a catch", style: .default) { [weak self] _ in self?.pickCatch(for: entry) })
        }
        if let choices = container.getPokemonForms.handle(GetPokemonFormsQuery(number: entry.number)) {
            sheet.addAction(UIAlertAction(title: "Form: \(choices.findName(of: entry.formId))", style: .default) { [weak self] _ in self?.pickForm(for: entry, from: choices) })
        }
        sheet.addAction(UIAlertAction(title: "Log a phase", style: .default) { [weak self] _ in self?.logPhase(for: entry) })
        sheet.addAction(UIAlertAction(title: "Remove from journey", style: .destructive) { [weak self] _ in self?.remove(entry) })
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        sheet.view.tintColor = Color.accent
        if let cell = tableView.cellForRow(at: indexPath) {
            sheet.popoverPresentationController?.sourceView = cell
            sheet.popoverPresentationController?.sourceRect = cell.bounds
        }
        present(sheet, animated: true)
    }

    fileprivate func pickCatch(for entry: JourneyEntryDetails) {
        let picker = LinkCatchTVC(target: makeLinkTarget(for: entry), catches: getLinkableCatches(for: entry)) { [weak self] caught in
            self?.link(caught, to: entry)
        }
        navigationController?.pushViewController(picker, animated: true)
    }

    fileprivate func pickForm(for entry: JourneyEntryDetails, from choices: FormChoices) {
        let picker = FormPicker.make(pokemonName: entry.pokemonName, choices: choices, selectedFormId: entry.formId) { [weak self] formId in
            guard let self = self else { return }
            self.container.updateJourney.handle(UpdateJourneyCommand(journeyId: self.journeyId, change: .setForm(entry: entry.id, formId: formId)))
        }
        navigationController?.pushViewController(picker, animated: true)
    }

    fileprivate func logPhase(for entry: JourneyEntryDetails) {
        let phaseCatches = container.getLinkableCatches.handle(GetLinkableCatchesQuery(journeyId: journeyId, entryId: entry.id, role: .phase))
        let picker = LinkCatchTVC(target: makeLinkTarget(for: entry), role: .phase, catches: phaseCatches) { [weak self] caught in
            guard let self = self else { return }
            self.container.updateJourney.handle(UpdateJourneyCommand(journeyId: self.journeyId, change: .addPhase(entry: entry.id, catchId: caught.id)))
            self.expandedEntryIds.insert(entry.id)
            Haptics.playSuccess()
        }
        navigationController?.pushViewController(picker, animated: true)
    }

    fileprivate func makeLinkTarget(for entry: JourneyEntryDetails) -> LinkCatchTarget {
        return LinkCatchTarget(number: entry.number, pokemonName: entry.pokemonName, linkedCatchId: entry.linkedCatch?.id, collectionName: "journey")
    }

    fileprivate func unlinkPhase(_ phase: CatchSummary, from entry: JourneyEntryDetails) {
        container.updateJourney.handle(UpdateJourneyCommand(journeyId: journeyId, change: .removePhase(entry: entry.id, catchId: phase.id)))
        reload()
    }

    fileprivate func togglePhases(of entry: JourneyEntryDetails) {
        guard !isReordering, let entryRow = pokemonRows.firstIndex(where: { row in
            if case .entry(let candidate) = row { return candidate.id == entry.id }
            return false
        }) else { return }
        let phaseIndexPaths = entry.phases.indices.map { IndexPath(row: entryRow + 1 + $0, section: 0) }
        let isExpanding = !expandedEntryIds.contains(entry.id)
        tableView.performBatchUpdates {
            if (isExpanding) {
                expandedEntryIds.insert(entry.id)
                tableView.insertRows(at: phaseIndexPaths, with: .fade)
            }
            else {
                expandedEntryIds.remove(entry.id)
                tableView.deleteRows(at: phaseIndexPaths, with: .fade)
            }
        }
        (tableView.cellForRow(at: IndexPath(row: entryRow, section: 0)) as? JourneyEntryCell)?.setPhasesExpanded(isExpanding)
    }

    fileprivate func link(_ caught: CatchSummary?, to entry: JourneyEntryDetails) {
        container.updateJourney.handle(UpdateJourneyCommand(journeyId: journeyId, change: .link(entry: entry.id, catchId: caught?.id)))
        if (caught != nil) {
            Haptics.playSuccess()
        }
        reload()
    }

    fileprivate func remove(_ entry: JourneyEntryDetails) {
        let removeEntry = { [weak self] in
            guard let self = self else { return }
            self.container.updateJourney.handle(UpdateJourneyCommand(journeyId: self.journeyId, change: .removeEntry(entry.id)))
            self.reload()
        }
        guard entry.linkedCatch != nil || !entry.phases.isEmpty else {
            removeEntry()
            return
        }
        let name = entry.pokemonName ?? "this Pokémon"
        presentDestructiveConfirmation(title: "Remove \(name)?",
                                       message: "Its linked catch and phases are unlinked from this journey. The catches stay in your collection.",
                                       destructiveTitle: "Remove",
                                       onConfirm: removeEntry)
    }

    fileprivate func showCatch(_ caught: CatchSummary) {
        guard let detail = CatchDetailTVC(container: container, catchId: caught.id) else { return }
        navigationController?.pushViewController(detail, animated: true)
    }

    // MARK: Journey actions

    @objc fileprivate func addPressed() {
        let picker = PokemonPickerModalVC(container: container, configuration: .addToJourney) { [weak self] _, picked in
            guard let self = self else { return }
            self.container.updateJourney.handle(UpdateJourneyCommand(journeyId: self.journeyId, change: .addPokemon(picked.map { $0.number })))
            self.mode = .pokemon
            self.header.selectMode(Mode.pokemon.rawValue)
            self.reload()
        }
        present(picker.wrapInSheet(), animated: true)
    }

    @objc fileprivate func morePressed() {
        let sheet = UIAlertController(title: journey.name, message: nil, preferredStyle: .actionSheet)
        if let playbackVC = JourneyPlaybackVC(container: container, journeyId: journeyId) {
            sheet.addAction(UIAlertAction(title: "Play journey", style: .default) { [weak self] _ in self?.present(playbackVC.wrapInSheet(), animated: true) })
        }
        sheet.addAction(UIAlertAction(title: "Rename", style: .default) { [weak self] _ in self?.rename() })
        if (journey.entries.count > 1) {
            sheet.addAction(UIAlertAction(title: isEditing ? "Done reordering" : "Reorder Pokémon", style: .default) { [weak self] _ in self?.toggleReordering() })
        }
        sheet.addAction(UIAlertAction(title: "Delete journey", style: .destructive) { [weak self] _ in self?.confirmDelete() })
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        sheet.view.tintColor = Color.accent
        sheet.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItems?.first
        present(sheet, animated: true)
    }

    fileprivate func rename() {
        presentTextInput(title: "Rename journey", text: journey.name, placeholder: "Journey name") { [weak self] name in
            guard let self = self else { return }
            self.container.updateJourney.handle(UpdateJourneyCommand(journeyId: self.journeyId, change: .rename(name)))
            self.reload()
        }
    }

    fileprivate func toggleReordering() {
        if (mode != .pokemon) {
            mode = .pokemon
            header.selectMode(Mode.pokemon.rawValue)
            reload()
        }
        isReordering = !isEditing
        if (isReordering && !expandedEntryIds.isEmpty) {
            expandedEntryIds.removeAll()
            tableView.reloadData()
        }
        setEditing(isReordering, animated: true)
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        if (!editing) {
            isReordering = false
        }
        super.setEditing(editing, animated: animated)
    }

    fileprivate func confirmDelete() {
        presentDestructiveConfirmation(title: "Delete \(journey.name)?",
                                       message: "The journey is removed. Your catches stay in your collection.",
                                       destructiveTitle: "Delete") { [weak self] in
            guard let self = self else { return }
            self.container.deleteJourney.handle(DeleteJourneyCommand(journeyId: self.journeyId))
            self.navigationController?.popViewController(animated: true)
        }
    }
}
