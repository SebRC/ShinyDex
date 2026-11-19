import UIKit

class JourneysTVC: UITableViewController {
	fileprivate let journeyService = JourneyService()
	fileprivate let pokemonService = PokemonService()
	fileprivate var journeys = [Journey]()
	fileprivate var catchesById = [UUID: Catch]()
	fileprivate var allPokemon = [Pokemon]()

	init() {
		super.init(style: .insetGrouped)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		title = "Journeys"
		navigationItem.largeTitleDisplayMode = .always
		let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPressed))
		addButton.accessibilityLabel = "New journey"
		navigationItem.rightBarButtonItem = addButton
		tableView.backgroundColor = Color.Grey900
		tableView.separatorColor = Color.Grey700
		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = 110
		tableView.register(JourneyCell.self, forCellReuseIdentifier: JourneyCell.reuseIdentifier)
		allPokemon = pokemonService.getAll()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		reloadJourneys()
	}

	fileprivate func reloadJourneys() {
		journeys = journeyService.getAll()
		catchesById = journeyService.catchesById()
		tableView.reloadData()
		tableView.backgroundView = journeys.isEmpty
			? EmptyStateView(symbolName: "map.fill",
							 title: "No journeys yet",
							 message: "Plan a shiny badge quest, a dream team or any other goal, and tick off each Pokémon as you catch it.")
			: nil
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return journeys.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: JourneyCell.reuseIdentifier, for: indexPath) as! JourneyCell
		let journey = journeys[indexPath.row]
		let members = journey.entries.compactMap { entry in
			allPokemon[safe: entry.number].map { (pokemon: $0, isCaught: journey.linkedCatch(for: entry, in: catchesById) != nil) }
		}
		cell.configure(name: journey.name, caught: journey.caughtCount(in: catchesById), members: members)
		return cell
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		navigationController?.pushViewController(JourneyDetailTVC(journey: journeys[indexPath.row]), animated: true)
	}

	override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		let journey = journeys[indexPath.row]
		let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, done in
			self?.confirmDelete(journey)
			done(false)
		}
		let rename = UIContextualAction(style: .normal, title: "Rename") { [weak self] _, _, done in
			self?.rename(journey)
			done(true)
		}
		rename.backgroundColor = Color.Grey600
		return UISwipeActionsConfiguration(actions: [delete, rename])
	}

	override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		let journey = journeys[indexPath.row]
		return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
			UIMenu(title: journey.name, children: [
				UIAction(title: "Rename", image: UIImage(systemName: "pencil")) { _ in self?.rename(journey) },
				UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in self?.confirmDelete(journey) }
			])
		}
	}

	fileprivate func rename(_ journey: Journey) {
		presentTextInput(title: "Rename journey", text: journey.name, placeholder: "Journey name") { [weak self] name in
			self?.journeyService.rename(journey, to: name)
			self?.reloadJourneys()
		}
	}

	fileprivate func confirmDelete(_ journey: Journey) {
		presentDestructiveConfirmation(title: "Delete \(journey.name)?",
									   message: "The journey is removed. Your catches stay in your collection.",
									   destructiveTitle: "Delete") { [weak self] in
			self?.journeyService.delete(journey)
			self?.reloadJourneys()
		}
	}

	@objc fileprivate func addPressed() {
		let picker = PokemonPickerModalVC(configuration: .newJourney) { [weak self] name, picked in
			guard let self = self else { return }
			let journey = self.journeyService.createJourney(named: name, numbers: picked.map { $0.number })
			self.navigationController?.pushViewController(JourneyDetailTVC(journey: journey), animated: true)
		}
		present(picker.inSheet(), animated: true)
	}
}

fileprivate class JourneyCell: UITableViewCell {
	static let reuseIdentifier = "journeyCell"
	fileprivate static let maximumSprites = 6

	fileprivate let nameLabel = UILabel(fontSize: 20, weight: .semibold)
	fileprivate let progressLabel = UILabel(fontSize: 13, color: Color.Grey400)
	fileprivate let progressBar = UIProgressView(progressViewStyle: .default)
	fileprivate let sprites = UIStackView()

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		backgroundColor = Color.Grey800
		let selectedBackground = UIView()
		selectedBackground.backgroundColor = Color.Grey700
		selectedBackgroundView = selectedBackground
		accessoryType = .disclosureIndicator
		progressLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 13, weight: .regular)
		progressBar.progressTintColor = Color.Orange500
		progressBar.trackTintColor = Color.Grey700
		progressBar.layer.cornerRadius = 2
		progressBar.clipsToBounds = true
		sprites.spacing = 2
		sprites.alignment = .center

		let stack = UIStackView(arrangedSubviews: [nameLabel, progressLabel, progressBar, sprites])
		stack.axis = .vertical
		stack.spacing = 3
		stack.setCustomSpacing(8, after: progressLabel)
		stack.setCustomSpacing(6, after: progressBar)
		contentView.addAutoLayoutSubviews(stack)
		NSLayoutConstraint.activate([
			stack.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
			stack.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
			stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
			stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
			progressBar.heightAnchor.constraint(equalToConstant: 4),
			sprites.heightAnchor.constraint(equalToConstant: 44)
		])
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func configure(name: String, caught: Int, members: [(pokemon: Pokemon, isCaught: Bool)]) {
		nameLabel.text = name
		let total = members.count
		progressLabel.text = total == 0 ? "No Pokémon yet" : (caught == total ? "Complete · all \(total) caught" : "\(caught) of \(total) caught")
		progressLabel.textColor = total > 0 && caught == total ? Color.Orange500 : Color.Grey400
		progressBar.progress = total == 0 ? 0 : Float(caught) / Float(total)

		for view in sprites.arrangedSubviews {
			view.removeFromSuperview()
		}
		for member in members.prefix(JourneyCell.maximumSprites) {
			let sprite = UIImageView(image: UIImage(named: member.pokemon.name.lowercased()))
			sprite.contentMode = .scaleAspectFit
			sprite.layer.magnificationFilter = .nearest
			sprite.alpha = member.isCaught ? 1 : 0.35
			sprite.widthAnchor.constraint(equalToConstant: 44).isActive = true
			sprite.heightAnchor.constraint(equalToConstant: 44).isActive = true
			sprites.addArrangedSubview(sprite)
		}
		if (members.count > JourneyCell.maximumSprites) {
			let more = UILabel(fontSize: 13, weight: .semibold, color: Color.Grey400)
			more.text = "+\(members.count - JourneyCell.maximumSprites)"
			sprites.addArrangedSubview(more)
		}
		sprites.addArrangedSubview(UIView())
		sprites.isHidden = members.isEmpty
		accessibilityLabel = "\(name), \(progressLabel.text ?? "")"
		accessibilityTraits = .button
	}
}
