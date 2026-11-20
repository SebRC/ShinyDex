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

		tableView.backgroundColor = Color.Grey900
		tableView.separatorColor = Color.Grey700
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
		return "Adding a Pokémon you've already caught doesn't tick it off. Tap it to link the catch you made for this journey, or to log phases you found along the way. Tap its phases to show them."
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
		link.backgroundColor = Color.Orange500
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
		sheet.addAction(UIAlertAction(title: "Log a phase", style: .default) { [weak self] _ in self?.logPhase(for: entry) })
		sheet.addAction(UIAlertAction(title: "Remove from journey", style: .destructive) { [weak self] _ in self?.remove(entry) })
		sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
		sheet.view.tintColor = Color.Orange500
		if let cell = tableView.cellForRow(at: indexPath) {
			sheet.popoverPresentationController?.sourceView = cell
			sheet.popoverPresentationController?.sourceRect = cell.bounds
		}
		present(sheet, animated: true)
	}

	fileprivate func pickCatch(for entry: JourneyEntryDetails) {
		let picker = LinkCatchTVC(container: container, journeyId: journeyId, entry: entry) { [weak self] caught in
			self?.link(caught, to: entry)
		}
		navigationController?.pushViewController(picker, animated: true)
	}

	fileprivate func logPhase(for entry: JourneyEntryDetails) {
		let picker = LinkCatchTVC(container: container, journeyId: journeyId, entry: entry, role: .phase) { [weak self] caught in
			guard let self = self else { return }
			self.container.updateJourney.handle(UpdateJourneyCommand(journeyId: self.journeyId, change: .addPhase(entry: entry.id, catchId: caught.id)))
			self.expandedEntryIds.insert(entry.id)
			Haptics.playSuccess()
		}
		navigationController?.pushViewController(picker, animated: true)
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
		sheet.addAction(UIAlertAction(title: "Rename", style: .default) { [weak self] _ in self?.rename() })
		if (journey.entries.count > 1) {
			sheet.addAction(UIAlertAction(title: isEditing ? "Done reordering" : "Reorder Pokémon", style: .default) { [weak self] _ in self?.toggleReordering() })
		}
		sheet.addAction(UIAlertAction(title: "Delete journey", style: .destructive) { [weak self] _ in self?.confirmDelete() })
		sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
		sheet.view.tintColor = Color.Orange500
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

fileprivate class JourneyHeaderView: UIView {
	var onModeChange: ((Int) -> Void)?
	var modeTitles = [String]() {
		didSet {
			modeControl.removeAllSegments()
			for (index, title) in modeTitles.enumerated() {
				modeControl.insertSegment(withTitle: title, at: index, animated: false)
			}
			modeControl.selectedSegmentIndex = 0
		}
	}

	fileprivate let countLabel = UILabel(fontSize: 34, weight: .bold, color: Color.Grey100)
	fileprivate let detailLabel = UILabel(fontSize: 13, color: Color.Grey400)
	fileprivate let progressBar = UIProgressView(progressViewStyle: .default)
	fileprivate let modeControl = UISegmentedControl()

	override init(frame: CGRect) {
		super.init(frame: frame)
		let card = UIView()
		card.backgroundColor = Color.Grey800
		card.layer.cornerRadius = 14
		let caption = UILabel(fontSize: 12, weight: .semibold, color: Color.Grey400)
		caption.text = "CAUGHT"
		countLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 34, weight: .bold)
		progressBar.progressTintColor = Color.Orange500
		progressBar.trackTintColor = Color.Grey700
		progressBar.layer.cornerRadius = 3
		progressBar.clipsToBounds = true
		let cardStack = UIStackView(arrangedSubviews: [caption, countLabel, detailLabel, progressBar])
		cardStack.axis = .vertical
		cardStack.spacing = 2
		cardStack.setCustomSpacing(12, after: detailLabel)
		card.addAutoLayoutSubviews(cardStack)
		cardStack.pinEdges(to: card, insets: UIEdgeInsets(top: 14, left: 16, bottom: 16, right: 16))
		card.isAccessibilityElement = true

		modeControl.selectedSegmentTintColor = Color.Orange500
		modeControl.backgroundColor = Color.Grey800
		modeControl.setTitleTextAttributes([.foregroundColor: Color.Grey900, .font: UIFont.systemFont(ofSize: 14, weight: .semibold)], for: .selected)
		modeControl.setTitleTextAttributes([.foregroundColor: Color.Grey300, .font: UIFont.systemFont(ofSize: 14, weight: .medium)], for: .normal)
		modeControl.addTarget(self, action: #selector(modeChanged), for: .valueChanged)

		let stack = UIStackView(arrangedSubviews: [card, modeControl])
		stack.axis = .vertical
		stack.spacing = 16
		preservesSuperviewLayoutMargins = true
		addAutoLayoutSubviews(stack)
		NSLayoutConstraint.activate([
			stack.topAnchor.constraint(equalTo: topAnchor, constant: 8),
			stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
			stack.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
			stack.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
			progressBar.heightAnchor.constraint(equalToConstant: 6),
			modeControl.heightAnchor.constraint(equalToConstant: 34)
		])
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func configure(caught: Int, total: Int, phases: Int, firstCatch: Date?) {
		countLabel.text = "\(caught) / \(total)"
		let phasesText = phases == 0 ? nil : (phases == 1 ? "1 phase" : "\(phases.grouped) phases")
		if (total > 0 && caught == total) {
			detailLabel.text = ["Journey complete", phasesText].compactMap { $0 }.joined(separator: " · ")
			detailLabel.textColor = Color.Orange500
		}
		else {
			let remaining = total - caught
			let remainingText = remaining == 1 ? "1 to go" : "\(remaining) to go"
			let firstCatchText = firstCatch.map { "first catch \(DateFormatter.localizedString(from: $0, dateStyle: .medium, timeStyle: .none))" }
			detailLabel.text = [remainingText, phasesText, firstCatchText].compactMap { $0 }.joined(separator: " · ")
			detailLabel.textColor = Color.Grey400
		}
		progressBar.progress = total == 0 ? 0 : Float(caught) / Float(total)
		countLabel.superview?.superview?.accessibilityLabel = "\(caught) of \(total) caught, \(detailLabel.text ?? "")"
	}

	func selectMode(_ index: Int) {
		modeControl.selectedSegmentIndex = index
	}

	@objc fileprivate func modeChanged() {
		onModeChange?(modeControl.selectedSegmentIndex)
	}
}

fileprivate class JourneyEntryCell: UITableViewCell {
	static let reuseIdentifier = "journeyEntryCell"

	fileprivate let sprite = UIImageView()
	fileprivate let nameLabel = UILabel(fontSize: 17, weight: .semibold)
	fileprivate let statusLabel = UILabel(fontSize: 13, color: Color.Grey400)
	fileprivate let phasesButton = UIButton(type: .system)
	fileprivate let ballView = UIImageView()
	fileprivate let statusIcon = UIImageView()
	fileprivate var phaseCount = 0
	var onPhasesTapped: (() -> Void)?

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		backgroundColor = Color.Grey800
		let selectedBackground = UIView()
		selectedBackground.backgroundColor = Color.Grey700
		selectedBackgroundView = selectedBackground
		sprite.contentMode = .scaleAspectFit
		sprite.layer.magnificationFilter = .nearest
		ballView.contentMode = .scaleAspectFit
		ballView.layer.magnificationFilter = .nearest
		statusIcon.contentMode = .center
		statusIcon.setContentHuggingPriority(.required, for: .horizontal)

		let statusRow = UIStackView(arrangedSubviews: [ballView, statusLabel])
		statusRow.spacing = 4
		statusRow.alignment = .center
		phasesButton.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
		phasesButton.tintColor = Color.Orange500
		phasesButton.semanticContentAttribute = .forceRightToLeft
		phasesButton.contentHorizontalAlignment = .leading
		phasesButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: -4)
		phasesButton.contentEdgeInsets = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 4)
		phasesButton.addTarget(self, action: #selector(phasesPressed), for: .touchUpInside)
		let labels = UIStackView(arrangedSubviews: [nameLabel, statusRow, phasesButton])
		labels.alignment = .leading
		labels.axis = .vertical
		labels.spacing = 2
		let row = UIStackView(arrangedSubviews: [sprite, labels, statusIcon])
		row.alignment = .center
		row.spacing = 12
		contentView.addAutoLayoutSubviews(row)
		NSLayoutConstraint.activate([
			row.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
			row.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
			row.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
			row.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
			sprite.widthAnchor.constraint(equalToConstant: 56),
			sprite.heightAnchor.constraint(equalToConstant: 56),
			ballView.widthAnchor.constraint(equalToConstant: 16),
			ballView.heightAnchor.constraint(equalToConstant: 16),
			statusIcon.widthAnchor.constraint(equalToConstant: 28)
		])
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func configure(entry: JourneyEntryDetails, phasesExpanded: Bool) {
		let linked = entry.linkedCatch
		let linkableCount = entry.linkableCatchCount
		let name = entry.pokemonName ?? "Unknown"
		sprite.image = entry.pokemonName.flatMap { UIImage(named: $0.lowercased()) }
		nameLabel.text = name
		sprite.alpha = linked == nil ? 0.4 : 1
		nameLabel.textColor = linked == nil ? Color.Grey300 : Color.Grey100

		if let linked = linked {
			var parts = [linked.ballName, linked.game.displayName]
			if let date = linked.formattedCaughtDate {
				parts.append(date)
			}
			if (linked.number != entry.number) {
				parts.insert("as \(linked.pokemonName)", at: 0)
			}
			statusLabel.text = parts.joined(separator: " · ")
			statusLabel.textColor = Color.Grey400
			ballView.image = UIImage(named: linked.caughtBall)
			ballView.isHidden = false
			statusIcon.image = UIImage.makeSymbol("checkmark.seal.fill", pointSize: 22, weight: .semibold)
			statusIcon.tintColor = Color.Orange500
		}
		else {
			statusLabel.text = linkableCount == 0 ? "Not caught yet" : (linkableCount == 1 ? "Not linked · 1 catch you can link" : "Not linked · \(linkableCount) catches you can link")
			statusLabel.textColor = linkableCount == 0 ? Color.Grey500 : Color.Grey300
			ballView.isHidden = true
			statusIcon.image = UIImage.makeSymbol(linkableCount == 0 ? "circle" : "link", pointSize: 18, weight: .semibold)
			statusIcon.tintColor = Color.Grey500
		}
		phaseCount = entry.phases.count
		phasesButton.setTitle(phaseCount == 1 ? "1 phase" : "\(phaseCount) phases", for: .normal)
		phasesButton.isHidden = phaseCount == 0
		setPhasesExpanded(phasesExpanded)
		accessibilityLabel = ["\(name), \(linked == nil ? "" : "caught, ")\(statusLabel.text ?? "")", phaseCount == 0 ? nil : phasesButton.currentTitle].compactMap { $0 }.joined(separator: ", ")
		accessibilityTraits = .button
	}

	func setPhasesExpanded(_ expanded: Bool) {
		phasesButton.setImage(UIImage.makeSymbol(expanded ? "chevron.up" : "chevron.down", pointSize: 11, weight: .bold), for: .normal)
		let toggleTitle = expanded ? "Hide phases" : "Show phases"
		phasesButton.accessibilityLabel = toggleTitle
		accessibilityCustomActions = phaseCount == 0 ? nil : [UIAccessibilityCustomAction(name: toggleTitle) { [weak self] _ in
			self?.onPhasesTapped?()
			return true
		}]
	}

	@objc fileprivate func phasesPressed() {
		onPhasesTapped?()
	}
}

fileprivate class PhaseCell: UITableViewCell {
	static let reuseIdentifier = "journeyPhaseCell"

	fileprivate let connector = UIView()
	fileprivate let sprite = UIImageView()
	fileprivate let titleLabel = UILabel(fontSize: 15, weight: .semibold)
	fileprivate let subtitleLabel = UILabel(fontSize: 12, color: Color.Grey400)
	fileprivate let outcomeView = UIImageView()

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		backgroundColor = Color.Grey800
		let selectedBackground = UIView()
		selectedBackground.backgroundColor = Color.Grey700
		selectedBackgroundView = selectedBackground
		accessoryType = .disclosureIndicator
		separatorInset = UIEdgeInsets(top: 0, left: 76, bottom: 0, right: 0)
		connector.backgroundColor = Color.Grey600
		for imageView in [sprite, outcomeView] {
			imageView.contentMode = .scaleAspectFit
			imageView.layer.magnificationFilter = .nearest
		}

		let labels = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
		labels.axis = .vertical
		labels.spacing = 1
		let row = UIStackView(arrangedSubviews: [sprite, labels, outcomeView])
		row.alignment = .center
		row.spacing = 8
		contentView.addAutoLayoutSubviews(connector, row)
		NSLayoutConstraint.activate([
			connector.centerXAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 36),
			connector.topAnchor.constraint(equalTo: contentView.topAnchor),
			connector.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			connector.widthAnchor.constraint(equalToConstant: 2),
			row.leadingAnchor.constraint(equalTo: connector.trailingAnchor, constant: 12),
			row.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
			row.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
			row.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
			sprite.widthAnchor.constraint(equalToConstant: 40),
			sprite.heightAnchor.constraint(equalToConstant: 40),
			outcomeView.widthAnchor.constraint(equalToConstant: 24),
			outcomeView.heightAnchor.constraint(equalToConstant: 24)
		])
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func configure(phase: CatchSummary) {
		sprite.image = UIImage(named: phase.pokemonName.lowercased())
		sprite.alpha = phase.isFailed ? 0.55 : 1
		titleLabel.text = [phase.nickname, phase.pokemonName].compactMap { $0 }.joined(separator: " · ")
		titleLabel.textColor = phase.isFailed ? Color.Grey300 : Color.Grey200
		let outcome = phase.isFailed ? "Got away" : phase.ballName
		subtitleLabel.text = [outcome, "\(phase.encounters.grouped) encounters", phase.formattedCaughtDate].compactMap { $0 }.joined(separator: " · ")
		outcomeView.image = phase.isFailed ? UIImage.makeSymbol("wind", pointSize: 15, weight: .semibold) : UIImage(named: phase.caughtBall)
		outcomeView.tintColor = Color.Grey500
		outcomeView.contentMode = phase.isFailed ? .center : .scaleAspectFit
		accessibilityLabel = "Phase, \(titleLabel.text ?? ""), \(subtitleLabel.text ?? "")"
	}
}

fileprivate class TimelineCell: UITableViewCell {
	static let reuseIdentifier = "timelineCell"

	fileprivate let topRail = UIView()
	fileprivate let bottomRail = UIView()
	fileprivate let dot = UILabel(fontSize: 12, weight: .bold, color: Color.Grey900)
	fileprivate let dateLabel = UILabel(fontSize: 13, weight: .semibold, color: Color.Orange500)
	fileprivate let gapLabel = UILabel(fontSize: 12, color: Color.Grey500)
	fileprivate let sprite = UIImageView()
	fileprivate let nameLabel = UILabel(fontSize: 17, weight: .semibold)
	fileprivate let detailLabel = UILabel(fontSize: 13, color: Color.Grey400)
	fileprivate let ballView = UIImageView()

	fileprivate static let dotSize: CGFloat = 24

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		backgroundColor = Color.Grey800
		let selectedBackground = UIView()
		selectedBackground.backgroundColor = Color.Grey700
		selectedBackgroundView = selectedBackground
		for rail in [topRail, bottomRail] {
			rail.backgroundColor = Color.Grey600
		}
		dot.backgroundColor = Color.Orange500
		dot.textAlignment = .center
		dot.font = UIFont.monospacedDigitSystemFont(ofSize: 12, weight: .bold)
		dot.layer.cornerRadius = TimelineCell.dotSize / 2
		dot.clipsToBounds = true
		sprite.contentMode = .scaleAspectFit
		sprite.layer.magnificationFilter = .nearest
		ballView.contentMode = .scaleAspectFit
		ballView.layer.magnificationFilter = .nearest
		detailLabel.numberOfLines = 0

		dateLabel.setContentHuggingPriority(.required, for: .horizontal)
		gapLabel.setContentHuggingPriority(.required, for: .horizontal)
		let dateRow = UIStackView(arrangedSubviews: [dateLabel, gapLabel, UIView()])
		dateRow.spacing = 6
		dateRow.alignment = .firstBaseline
		let labels = UIStackView(arrangedSubviews: [dateRow, nameLabel, detailLabel])
		labels.axis = .vertical
		labels.spacing = 2
		let content = UIStackView(arrangedSubviews: [labels, sprite])
		content.alignment = .center
		content.spacing = 8

		contentView.addAutoLayoutSubviews(topRail, bottomRail, dot, content, ballView)
		NSLayoutConstraint.activate([
			dot.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			dot.widthAnchor.constraint(equalToConstant: TimelineCell.dotSize),
			dot.heightAnchor.constraint(equalToConstant: TimelineCell.dotSize),
			dot.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
			topRail.centerXAnchor.constraint(equalTo: dot.centerXAnchor),
			topRail.widthAnchor.constraint(equalToConstant: 2),
			topRail.topAnchor.constraint(equalTo: contentView.topAnchor),
			topRail.bottomAnchor.constraint(equalTo: dot.topAnchor),
			bottomRail.centerXAnchor.constraint(equalTo: dot.centerXAnchor),
			bottomRail.widthAnchor.constraint(equalToConstant: 2),
			bottomRail.topAnchor.constraint(equalTo: dot.bottomAnchor),
			bottomRail.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			content.leadingAnchor.constraint(equalTo: dot.trailingAnchor, constant: 14),
			content.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
			content.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
			content.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
			sprite.widthAnchor.constraint(equalToConstant: 64),
			sprite.heightAnchor.constraint(equalToConstant: 64),
			ballView.widthAnchor.constraint(equalToConstant: 20),
			ballView.heightAnchor.constraint(equalToConstant: 20),
			ballView.trailingAnchor.constraint(equalTo: sprite.trailingAnchor),
			ballView.bottomAnchor.constraint(equalTo: sprite.bottomAnchor)
		])
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func configure(catchNumber: Int?, step: JourneyTimelineStep, previousDate: Date?, isFirst: Bool, isLast: Bool) {
		let caught = step.caught
		if let catchNumber = catchNumber {
			dot.font = UIFont.monospacedDigitSystemFont(ofSize: 12, weight: .bold)
			dot.text = "\(catchNumber)"
			dot.backgroundColor = Color.Orange500
		}
		else {
			let sparkle = UIImage.makeSymbol("sparkle", pointSize: 11, weight: .bold)?.withTintColor(Color.Grey900, renderingMode: .alwaysOriginal)
			dot.attributedText = sparkle.map { NSAttributedString(attachment: NSTextAttachment(image: $0)) }
			dot.backgroundColor = Color.Grey500
		}
		dot.textAlignment = .center
		topRail.isHidden = isFirst
		bottomRail.isHidden = isLast
		dateLabel.text = caught.formattedCaughtDate ?? "Undated"
		gapLabel.text = TimelineCell.formatGap(from: previousDate, to: caught.caughtDate)
		gapLabel.isHidden = gapLabel.text == nil
		let name = caught.pokemonName
		nameLabel.text = name
		sprite.image = UIImage(named: name.lowercased())
		ballView.image = UIImage(named: caught.caughtBall)
		ballView.isHidden = caught.isFailed
		let outcome = caught.isFailed ? "Got away" : caught.ballName
		let details = "\(caught.encounters.grouped) encounters\n\(outcome) · \(caught.game.displayName)"
		detailLabel.text = step.isPhase ? "Phase while hunting \(step.entryPokemonName ?? "Unknown")\n\(details)" : details
		let stepTitle = catchNumber.map { "Catch \($0)" } ?? "Phase"
		accessibilityLabel = "\(stepTitle), \(name), \(dateLabel.text ?? ""), \(gapLabel.text ?? ""), \(detailLabel.text ?? "")"
		accessibilityTraits = .button
	}

	fileprivate static func formatGap(from previous: Date?, to date: Date?) -> String? {
		guard let previous = previous, let date = date else { return nil }
		let days = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: previous), to: Calendar.current.startOfDay(for: date)).day ?? 0
		switch days {
		case 0: return "same day"
		case 1: return "+1 day"
		default: return "+\(days.grouped) days"
		}
	}
}
