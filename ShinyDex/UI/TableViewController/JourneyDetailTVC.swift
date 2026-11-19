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

	fileprivate let journey: Journey
	fileprivate let journeyService = JourneyService()
	fileprivate let allPokemon = PokemonService().getAll()
	fileprivate var catchesById = [UUID: Catch]()
	fileprivate var timeline = [(entry: JourneyEntry, caught: Catch)]()
	fileprivate let header = JourneyHeaderView()
	fileprivate var mode = Mode.pokemon

	init(journey: Journey) {
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

	fileprivate func reload() {
		title = journey.name
		catchesById = journeyService.catchesById()
		timeline = journey.timeline(in: catchesById)
		header.configure(caught: journey.caughtCount(in: catchesById), total: journey.entries.count, firstCatch: timeline.first?.caught.caughtDate)
		tableView.reloadData()
		updateEmptyState()
	}

	fileprivate func updateEmptyState() {
		switch mode {
		case .pokemon where journey.entries.isEmpty:
			tableView.backgroundView = EmptyStateView(symbolName: "plus.circle", title: "No Pokémon yet", message: "Tap + to add the Pokémon this journey is about.")
		case .timeline where timeline.isEmpty:
			tableView.backgroundView = EmptyStateView(symbolName: "calendar", title: "Nothing caught yet", message: "Link a catch to a Pokémon in this journey and it shows up here, in the order you caught them.")
		default:
			tableView.backgroundView = nil
		}
		tableView.backgroundView?.isUserInteractionEnabled = false
	}

	fileprivate func pokemon(number: Int) -> Pokemon? {
		return allPokemon[safe: number]
	}

	// MARK: Table

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return mode == .pokemon ? journey.entries.count : timeline.count
	}

	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		guard mode == .pokemon, !journey.entries.isEmpty else { return nil }
		return "Adding a Pokémon you've already caught doesn't tick it off. Tap it and link the catch you made for this journey."
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch mode {
		case .pokemon:
			let cell = tableView.dequeueReusableCell(withIdentifier: JourneyEntryCell.reuseIdentifier, for: indexPath) as! JourneyEntryCell
			let entry = journey.entries[indexPath.row]
			let linked = journey.linkedCatch(for: entry, in: catchesById)
			let linkable = linked == nil ? journeyService.linkableCatches(for: entry, in: journey).count : 0
			cell.configure(pokemon: pokemon(number: entry.number), linked: linked, linkedPokemon: linked.flatMap { pokemon(number: $0.number) }, linkableCount: linkable)
			return cell
		case .timeline:
			let cell = tableView.dequeueReusableCell(withIdentifier: TimelineCell.reuseIdentifier, for: indexPath) as! TimelineCell
			let item = timeline[indexPath.row]
			let previousDate = indexPath.row > 0 ? timeline[indexPath.row - 1].caught.caughtDate : nil
			cell.configure(step: indexPath.row + 1,
						   caught: item.caught,
						   pokemon: pokemon(number: item.caught.number),
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
			showActions(for: journey.entries[indexPath.row], at: indexPath)
		case .timeline:
			showCatch(timeline[indexPath.row].caught)
		}
	}

	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return mode == .pokemon
	}

	override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
		return mode == .pokemon
	}

	override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
		journeyService.moveEntry(from: sourceIndexPath.row, to: destinationIndexPath.row, in: journey)
	}

	override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		guard mode == .pokemon else { return nil }
		let entry = journey.entries[indexPath.row]
		let remove = UIContextualAction(style: .destructive, title: "Remove") { [weak self] _, _, done in
			self?.remove(entry)
			done(false)
		}
		return UISwipeActionsConfiguration(actions: [remove])
	}

	override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		guard mode == .pokemon else { return nil }
		let entry = journey.entries[indexPath.row]
		guard journey.linkedCatch(for: entry, in: catchesById) == nil, !journeyService.linkableCatches(for: entry, in: journey).isEmpty else { return nil }
		let link = UIContextualAction(style: .normal, title: "Link catch") { [weak self] _, _, done in
			self?.pickCatch(for: entry)
			done(true)
		}
		link.backgroundColor = Color.Orange500
		return UISwipeActionsConfiguration(actions: [link])
	}

	// MARK: Entry actions

	fileprivate func showActions(for entry: JourneyEntry, at indexPath: IndexPath) {
		let name = pokemon(number: entry.number)?.name ?? "this Pokémon"
		let linked = journey.linkedCatch(for: entry, in: catchesById)
		let linkable = journeyService.linkableCatches(for: entry, in: journey)
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
		sheet.addAction(UIAlertAction(title: "Remove from journey", style: .destructive) { [weak self] _ in self?.remove(entry) })
		sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
		sheet.view.tintColor = Color.Orange500
		if let cell = tableView.cellForRow(at: indexPath) {
			sheet.popoverPresentationController?.sourceView = cell
			sheet.popoverPresentationController?.sourceRect = cell.bounds
		}
		present(sheet, animated: true)
	}

	fileprivate func pickCatch(for entry: JourneyEntry) {
		let picker = LinkCatchTVC(entry: entry, journey: journey, allPokemon: allPokemon) { [weak self] caught in
			self?.link(caught, to: entry)
		}
		navigationController?.pushViewController(picker, animated: true)
	}

	fileprivate func link(_ caught: Catch?, to entry: JourneyEntry) {
		journeyService.link(caught, toEntry: entry.id, in: journey)
		if (caught != nil) {
			Haptics.success()
		}
		reload()
	}

	fileprivate func remove(_ entry: JourneyEntry) {
		let removeEntry = { [weak self] in
			guard let self = self else { return }
			self.journeyService.removeEntry(entry.id, from: self.journey)
			self.reload()
		}
		guard journey.linkedCatch(for: entry, in: catchesById) != nil else {
			removeEntry()
			return
		}
		let name = pokemon(number: entry.number)?.name ?? "this Pokémon"
		presentDestructiveConfirmation(title: "Remove \(name)?",
									   message: "Its linked catch is unlinked from this journey. The catch stays in your collection.",
									   destructiveTitle: "Remove",
									   onConfirm: removeEntry)
	}

	fileprivate func showCatch(_ caught: Catch) {
		guard let pokemon = pokemon(number: caught.number) else { return }
		navigationController?.pushViewController(CatchDetailTVC(caught: caught, pokemon: pokemon), animated: true)
	}

	// MARK: Journey actions

	@objc fileprivate func addPressed() {
		let picker = PokemonPickerModalVC(configuration: .addToJourney) { [weak self] _, picked in
			guard let self = self else { return }
			self.journeyService.add(numbers: picked.map { $0.number }, to: self.journey)
			self.mode = .pokemon
			self.header.selectMode(Mode.pokemon.rawValue)
			self.reload()
		}
		present(picker.inSheet(), animated: true)
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
			self.journeyService.rename(self.journey, to: name)
			self.reload()
		}
	}

	fileprivate func toggleReordering() {
		if (mode != .pokemon) {
			mode = .pokemon
			header.selectMode(Mode.pokemon.rawValue)
			reload()
		}
		setEditing(!isEditing, animated: true)
	}

	fileprivate func confirmDelete() {
		presentDestructiveConfirmation(title: "Delete \(journey.name)?",
									   message: "The journey is removed. Your catches stay in your collection.",
									   destructiveTitle: "Delete") { [weak self] in
			guard let self = self else { return }
			self.journeyService.delete(self.journey)
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

	func configure(caught: Int, total: Int, firstCatch: Date?) {
		countLabel.text = "\(caught) / \(total)"
		if (total > 0 && caught == total) {
			detailLabel.text = "Journey complete"
			detailLabel.textColor = Color.Orange500
		}
		else {
			let remaining = total - caught
			let remainingText = remaining == 1 ? "1 to go" : "\(remaining) to go"
			detailLabel.text = firstCatch.map { "\(remainingText) · first catch \(DateFormatter.localizedString(from: $0, dateStyle: .medium, timeStyle: .none))" } ?? remainingText
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
	fileprivate let ballView = UIImageView()
	fileprivate let statusIcon = UIImageView()

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
		let labels = UIStackView(arrangedSubviews: [nameLabel, statusRow])
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

	func configure(pokemon: Pokemon?, linked: Catch?, linkedPokemon: Pokemon?, linkableCount: Int) {
		let name = pokemon?.name ?? "Unknown"
		sprite.image = pokemon.flatMap { UIImage(named: $0.name.lowercased()) }
		nameLabel.text = name
		sprite.alpha = linked == nil ? 0.4 : 1
		nameLabel.textColor = linked == nil ? Color.Grey300 : Color.Grey100

		if let linked = linked {
			var parts = [linked.ballName, linked.game.displayName]
			if let date = linked.formattedCaughtDate {
				parts.append(date)
			}
			if let linkedPokemon = linkedPokemon, linkedPokemon.number != pokemon?.number {
				parts.insert("as \(linkedPokemon.name)", at: 0)
			}
			statusLabel.text = parts.joined(separator: " · ")
			statusLabel.textColor = Color.Grey400
			ballView.image = UIImage(named: linked.caughtBall)
			ballView.isHidden = false
			statusIcon.image = UIImage.symbol("checkmark.seal.fill", pointSize: 22, weight: .semibold)
			statusIcon.tintColor = Color.Orange500
		}
		else {
			statusLabel.text = linkableCount == 0 ? "Not caught yet" : (linkableCount == 1 ? "Not linked · 1 catch you can link" : "Not linked · \(linkableCount) catches you can link")
			statusLabel.textColor = linkableCount == 0 ? Color.Grey500 : Color.Grey300
			ballView.isHidden = true
			statusIcon.image = UIImage.symbol(linkableCount == 0 ? "circle" : "link", pointSize: 18, weight: .semibold)
			statusIcon.tintColor = Color.Grey500
		}
		accessibilityLabel = "\(name), \(linked == nil ? "" : "caught, ")\(statusLabel.text ?? "")"
		accessibilityTraits = .button
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

	func configure(step: Int, caught: Catch, pokemon: Pokemon?, previousDate: Date?, isFirst: Bool, isLast: Bool) {
		dot.text = "\(step)"
		topRail.isHidden = isFirst
		bottomRail.isHidden = isLast
		dateLabel.text = caught.formattedCaughtDate ?? "Undated"
		gapLabel.text = TimelineCell.gapText(from: previousDate, to: caught.caughtDate)
		gapLabel.isHidden = gapLabel.text == nil
		let name = pokemon?.name ?? "Unknown"
		nameLabel.text = name
		sprite.image = pokemon.flatMap { UIImage(named: $0.name.lowercased()) }
		ballView.image = UIImage(named: caught.caughtBall)
		detailLabel.text = "\(caught.encounters.grouped) encounters\n\(caught.ballName) · \(caught.game.displayName)"
		accessibilityLabel = "Catch \(step), \(name), \(dateLabel.text ?? ""), \(gapLabel.text ?? ""), \(detailLabel.text ?? "")"
		accessibilityTraits = .button
	}

	fileprivate static func gapText(from previous: Date?, to date: Date?) -> String? {
		guard let previous = previous, let date = date else { return nil }
		let days = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: previous), to: Calendar.current.startOfDay(for: date)).day ?? 0
		switch days {
		case 0: return "same day"
		case 1: return "+1 day"
		default: return "+\(days.grouped) days"
		}
	}
}
