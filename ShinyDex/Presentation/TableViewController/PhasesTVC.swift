import UIKit

final class PhasesTVC: UITableViewController {
    fileprivate static let cellIdentifier = "phaseCell"
    fileprivate static let spriteSide: CGFloat = 48

    fileprivate let container: AppContainer
    fileprivate let source: GetPhasesQuery.Source
    fileprivate var list: PhaseList?
    fileprivate let phaseTile = StatTile(caption: "Phase")
    fileprivate let encountersTile = StatTile(caption: "This phase")

    var onChange: (() -> Void)?

    init(container: AppContainer, source: GetPhasesQuery.Source) {
        self.container = container
        self.source = source
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Phases"
        navigationItem.largeTitleDisplayMode = .never
        tableView.backgroundColor = Color.background
        tableView.separatorColor = Color.separator
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: PhasesTVC.cellIdentifier)
        let addButton = UIBarButtonItem(image: UIImage(systemName: "plus.circle"), style: .plain, target: self, action: #selector(addPhasePressed))
        addButton.accessibilityLabel = "Add a phase"
        navigationItem.rightBarButtonItem = addButton
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadPhases()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layOutHeader()
    }

    // MARK: Data

    fileprivate func reloadPhases() {
        list = container.getPhases.handle(GetPhasesQuery(source: source))
        updateSummary()
        tableView.reloadData()
        updateEmptyState()
    }

    fileprivate func updateSummary() {
        guard let list = list else { return }
        if (list.isHunt) {
            phaseTile.setCaption("Phase")
            phaseTile.setValue("\(list.phases.count + 1)", isEmphasized: true)
            encountersTile.setCaption("This phase")
        }
        else {
            phaseTile.setCaption("Phases")
            phaseTile.setValue("\(list.phases.count)", isEmphasized: true)
            encountersTile.setCaption("Final phase")
        }
        encountersTile.setValue(list.encountersAfterPhases.grouped)
        encountersTile.setDetail(list.encountersAfterPhases == 1 ? "encounter" : "encounters")
    }

    fileprivate func layOutHeader() {
        let width = tableView.bounds.width
        guard width > 0 else { return }
        let header = tableView.tableHeaderView ?? makeHeader()
        let height = header.systemLayoutSizeFitting(CGSize(width: width, height: UIView.layoutFittingCompressedSize.height), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel).height
        guard tableView.tableHeaderView !== header || header.frame.size != CGSize(width: width, height: height) else { return }
        header.frame = CGRect(x: 0, y: 0, width: width, height: height)
        tableView.tableHeaderView = header
    }

    fileprivate func makeHeader() -> UIView {
        let tiles = UIStackView(arrangedSubviews: [phaseTile, encountersTile])
        tiles.distribution = .fillEqually
        tiles.spacing = Spacing.medium
        let header = UIView()
        header.addAutoLayoutSubviews(tiles)
        tiles.pinEdges(to: header, insets: UIEdgeInsets(top: Spacing.small, left: Spacing.screenMargin, bottom: Spacing.small, right: Spacing.screenMargin))
        return header
    }

    fileprivate func updateEmptyState() {
        guard let list = list, list.phases.isEmpty else {
            tableView.backgroundView = nil
            return
        }
        let message = list.isHunt
            ? "Found a different shiny while hunting \(list.targetName)? Log it as a phase with the + button."
            : "Found other shinies while hunting this one? Link them as phases with the + button."
        tableView.backgroundView = EmptyStateView(symbolName: "arrow.triangle.branch", title: "No phases", message: message)
    }

    // MARK: Actions

    @objc fileprivate func addPhasePressed() {
        switch source {
        case .hunt(let huntedNumber):
            logPhase(huntedNumber: huntedNumber)
        case .caught(let catchId):
            linkPhase(to: catchId)
        }
    }

    fileprivate func logPhase(huntedNumber: Int) {
        let picker = PokemonPickerModalVC(container: container, configuration: .logPhase) { [weak self] _, picked in
            guard let self = self, let found = picked.first else { return }
            let logSheet = PokeballModalVC(container: self.container, number: found.number, pokemonName: found.name, phaseOf: huntedNumber) { [weak self] _ in
                self?.reloadPhases()
                self?.onChange?()
            }
            self.present(logSheet.wrapInSheet(), animated: true)
        }
        present(picker.wrapInSheet(), animated: true)
    }

    fileprivate func linkPhase(to catchId: CatchID) {
        guard let list = list, let target = container.getCatchDetails.handle(GetCatchDetailsQuery(catchId: catchId))?.summary else { return }
        let candidates = container.getPhaseCandidates.handle(GetPhaseCandidatesQuery(catchId: catchId))
        let linkTarget = LinkCatchTarget(number: target.number, pokemonName: list.targetName, linkedCatchId: nil, collectionName: "hunt")
        let picker = LinkCatchTVC(target: linkTarget, role: .phase, catches: candidates) { [weak self] phase in
            self?.container.changeCatchPhases.handle(ChangeCatchPhasesCommand(catchId: catchId, change: .link(phase.id)))
            Haptics.playSuccess()
            self?.onChange?()
        }
        navigationController?.pushViewController(picker, animated: true)
    }

    fileprivate func unlink(_ phase: PhaseList.Phase) {
        switch source {
        case .hunt(let huntedNumber):
            container.unlinkPhase.handle(UnlinkPhaseCommand(huntedNumber: huntedNumber, catchId: phase.caught.id))
        case .caught(let catchId):
            container.changeCatchPhases.handle(ChangeCatchPhasesCommand(catchId: catchId, change: .unlink(phase.caught.id)))
        }
        Haptics.tap()
        reloadPhases()
        onChange?()
    }

    // MARK: Table view

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list?.phases.count ?? 0
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard let list = list, !list.phases.isEmpty else { return nil }
        let encounters = list.isHunt ? "" : " Each phase's encounters come from its catch."
        return "Swipe to remove a phase. The shiny stays in your collection.\(encounters)"
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PhasesTVC.cellIdentifier, for: indexPath)
        guard let phase = list?.phases[indexPath.row] else { return cell }
        var content = UIListContentConfiguration.subtitleCell()
        content.image = phase.caught.spriteImage
        content.imageProperties.maximumSize = CGSize(width: PhasesTVC.spriteSide, height: PhasesTVC.spriteSide)
        content.imageProperties.reservedLayoutSize = CGSize(width: PhasesTVC.spriteSide, height: PhasesTVC.spriteSide)
        content.text = "Phase \(indexPath.row + 1) · \(phase.caught.nickname ?? phase.caught.speciesTitle)"
        content.textProperties.font = UIFont.make(.body, weight: .semibold)
        content.textProperties.color = Color.textPrimary
        let encounters = phase.encounters == 1 ? "1 encounter" : "\(phase.encounters.grouped) encounters"
        content.secondaryText = ([encounters, "found at \(phase.foundAt.grouped)"] + (phase.caught.isFailed ? ["got away"] : [])).joined(separator: " · ")
        content.secondaryTextProperties.font = UIFont.make(.footnote)
        content.secondaryTextProperties.color = Color.textTertiary
        cell.contentConfiguration = content
        cell.backgroundColor = Color.surface
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let phase = list?.phases[indexPath.row], let detail = CatchDetailTVC(container: container, catchId: phase.caught.id) else { return }
        navigationController?.pushViewController(detail, animated: true)
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let list = list else { return nil }
        let phase = list.phases[indexPath.row]
        let remove = UIContextualAction(style: .destructive, title: "Remove") { [weak self] _, _, completion in
            self?.unlink(phase)
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [remove])
    }
}
