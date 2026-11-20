import UIKit

class CatchDetailTVC: UITableViewController {
	fileprivate enum Section: Int, CaseIterable {
		case hero
		case stats
		case about
		case training
		case details
	}

	fileprivate enum AboutRow: CaseIterable {
		case nickname
		case gender
		case nature
		case ivs
	}

	fileprivate enum TrainingRow {
		case evs
		case evolve
	}

	fileprivate enum Field {
		case ball
		case game
		case method
		case encounters
		case caughtDate
	}

	fileprivate struct Row {
		let field: Field
		let title: String
		let value: String
		let image: UIImage?
		var isSymbol = false
	}

	fileprivate let container: AppContainer
	fileprivate let catchId: CatchID
	fileprivate var details: CatchDetails
	fileprivate var caught: CatchSummary {
		return details.summary
	}
	fileprivate lazy var ballGrid = BallGrid(container: container)
	fileprivate var aboutRows = [AboutRow]()
	fileprivate var trainingRows = [TrainingRow]()
	fileprivate let cellIdentifier = "catchDetailCell"
	fileprivate var rows = [Row]()
	fileprivate var positionText: String?

	init?(container: AppContainer, catchId: CatchID) {
		guard let details = container.getCatchDetails.handle(GetCatchDetailsQuery(catchId: catchId)) else { return nil }
		self.container = container
		self.catchId = catchId
		self.details = details
		super.init(style: .insetGrouped)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		title = caught.isFailed ? "\(caught.pokemonName) (got away)" : caught.pokemonName
		navigationItem.largeTitleDisplayMode = .never
		tableView.backgroundColor = Color.Grey900
		tableView.separatorColor = Color.Grey700
		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = 56
		tableView.register(CatchHeroCell.self, forCellReuseIdentifier: CatchHeroCell.reuseIdentifier)
		tableView.register(CatchStatsCell.self, forCellReuseIdentifier: CatchStatsCell.reuseIdentifier)
		reloadRows()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		if (isMovingToParent == false) {
			reloadRows()
		}
	}

	fileprivate func reloadRows() {
		if let updated = container.getCatchDetails.handle(GetCatchDetailsQuery(catchId: catchId)) {
			details = updated
		}
		let gameCover = GamesList.games[caught.game].flatMap { UIImage(named: $0.coverPokemon) }
		rows = [
			Row(field: .ball, title: "Ball", value: caught.ballName, image: UIImage(named: caught.caughtBall)),
			Row(field: .game, title: "Game", value: caught.game.displayName, image: gameCover),
			Row(field: .method, title: "Method", value: caught.huntMethod.rawValue, image: UIImage(named: caught.huntMethod.rawValue)),
			Row(field: .encounters, title: "Encounters", value: caught.encounters.grouped, image: UIImage.makeSymbol("number", pointSize: 18, weight: .medium), isSymbol: true),
			Row(field: .caughtDate, title: caught.isFailed ? "Found" : "Caught", value: caught.formattedCaughtDate ?? "Unknown", image: UIImage.makeSymbol("calendar", pointSize: 18, weight: .medium), isSymbol: true)
		]
		if (caught.isFailed) {
			rows.removeAll { $0.field == .ball }
		}
		aboutRows = caught.isFailed ? [] : AboutRow.allCases
		trainingRows = caught.isFailed ? [] : [.evs]
		if (!caught.isFailed && !details.evolutionTargets.isEmpty) {
			trainingRows.append(.evolve)
		}
		title = caught.isFailed ? "\(caught.pokemonName) (got away)" : caught.pokemonName
		if let position = details.position {
			positionText = "Catch \(position + 1) of \(details.speciesCatchCount)"
		}
		else {
			positionText = nil
		}
		tableView.reloadData()
	}

	fileprivate func save(_ change: UpdateCatchCommand.Change) {
		try? container.updateCatch.handle(UpdateCatchCommand(catchId: catchId, change: change))
		reloadRows()
	}

	// MARK: Odds and luck

	fileprivate var luckText: String? {
		guard let chance = details.chanceOfFindingSooner else { return nil }
		if (chance <= 50) {
			return "Luckier than \(Int((100 - chance).rounded()))% of hunts at these odds"
		}
		return "Took longer than \(Int(chance.rounded()))% of hunts at these odds"
	}

	// MARK: Table

	override func numberOfSections(in tableView: UITableView) -> Int {
		return Section.allCases.count
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch Section(rawValue: section)! {
		case .details: return rows.count
		case .about: return aboutRows.count
		case .training: return trainingRows.count
		default: return 1
		}
	}

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch Section(rawValue: section)! {
		case .details: return "Details"
		case .about: return aboutRows.isEmpty ? nil : "About"
		case .training: return trainingRows.isEmpty ? nil : "Training"
		default: return nil
		}
	}

	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		return Section(rawValue: section) == .details ? "Tap a detail to change it." : nil
	}

	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		switch Section(rawValue: section)! {
		case .details: return UITableView.automaticDimension
		case .about: return aboutRows.isEmpty ? 4 : UITableView.automaticDimension
		case .training: return trainingRows.isEmpty ? 4 : UITableView.automaticDimension
		default: return 4
		}
	}

	override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return Section(rawValue: section) == .details ? UITableView.automaticDimension : 4
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch Section(rawValue: indexPath.section)! {
		case .hero:
			let cell = tableView.dequeueReusableCell(withIdentifier: CatchHeroCell.reuseIdentifier, for: indexPath) as! CatchHeroCell
			let verb = caught.isFailed ? "Found" : "Caught"
			cell.configure(pokemonName: caught.pokemonName,
						   nickname: caught.nickname,
						   genderSymbol: caught.gender?.symbol,
						   dateText: caught.formattedCaughtDate.map { "\(verb) \($0)" } ?? "Logged before catch history",
						   positionText: positionText,
						   isFailed: caught.isFailed)
			return cell
		case .stats:
			let cell = tableView.dequeueReusableCell(withIdentifier: CatchStatsCell.reuseIdentifier, for: indexPath) as! CatchStatsCell
			cell.configure(encounters: caught.encounters.grouped, odds: details.odds.map { "1/\($0.grouped)" } ?? "Varies", luck: luckText)
			return cell
		case .about:
			return makeAboutCell(for: aboutRows[indexPath.row])
		case .training:
			return makeTrainingCell(for: trainingRows[indexPath.row])
		case .details:
			return makeDetailCell(for: rows[indexPath.row])
		}
	}

	fileprivate func makeAboutCell(for row: AboutRow) -> UITableViewCell {
		let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
		cell.backgroundColor = Color.Grey800
		let selectedBackground = UIView()
		selectedBackground.backgroundColor = Color.Grey700
		cell.selectedBackgroundView = selectedBackground
		cell.textLabel?.textColor = Color.Grey200
		cell.detailTextLabel?.textColor = Color.Grey400
		cell.accessoryType = .disclosureIndicator
		let symbol: String
		switch row {
		case .nickname:
			cell.textLabel?.text = "Nickname"
			cell.detailTextLabel?.text = caught.nickname ?? "None"
			symbol = "tag.fill"
		case .gender:
			cell.textLabel?.text = "Gender"
			cell.detailTextLabel?.text = caught.gender.map { [$0.symbol, $0.name].compactMap { $0 }.joined(separator: " ") } ?? "Unknown"
			symbol = "person.fill"
		case .nature:
			cell.textLabel?.text = "Nature"
			cell.detailTextLabel?.text = caught.nature.map { "\($0.name) · \($0.effectSummary)" } ?? "Unknown"
			symbol = "leaf.fill"
		case .ivs:
			cell.textLabel?.text = "IVs"
			let ivsText = NSMutableAttributedString(string: caught.ivs.isEmpty ? "" : "\(caught.ivs.perfectCount) perfect · ", attributes: [.foregroundColor: Color.Grey400])
			ivsText.append(caught.ivs.makeColoredSummary(unknownColor: Color.Grey400))
			cell.detailTextLabel?.attributedText = ivsText
			symbol = "chart.bar.fill"
		}
		cell.imageView?.image = UIImage.makeSymbol(symbol, pointSize: 18, weight: .medium)?.padded(to: CGSize(width: 30, height: 30))
		cell.imageView?.tintColor = Color.Orange500
		return cell
	}

	fileprivate func makeTrainingCell(for row: TrainingRow) -> UITableViewCell {
		let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
		cell.backgroundColor = Color.Grey800
		let selectedBackground = UIView()
		selectedBackground.backgroundColor = Color.Grey700
		cell.selectedBackgroundView = selectedBackground
		cell.textLabel?.textColor = Color.Grey200
		cell.textLabel?.font = UIFont.systemFont(ofSize: 17)
		cell.detailTextLabel?.textColor = Color.Grey400
		cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 13)
		cell.accessoryType = .disclosureIndicator
		let iconSize = CGSize(width: 30, height: 30)
		switch row {
		case .evs:
			cell.textLabel?.text = "EV training"
			cell.detailTextLabel?.text = caught.evs.isEmpty ? "Not trained yet" : "\(caught.evs.summary) · \(caught.evs.total)/\(EffortValues.maximumTotal)"
			cell.imageView?.image = UIImage.makeSymbol("bolt.fill", pointSize: 18, weight: .medium)?.padded(to: iconSize)
		case .evolve:
			cell.textLabel?.text = "Evolve"
			let names = details.evolutionTargets.map { $0.name }
			let origin = details.evolvedFromName.map { "Caught as \($0) · " } ?? ""
			cell.detailTextLabel?.text = origin + names.joined(separator: ", ")
			cell.imageView?.image = UIImage.makeSymbol("arrow.2.circlepath", pointSize: 18, weight: .medium)?.padded(to: iconSize)
		}
		cell.imageView?.tintColor = Color.Orange500
		return cell
	}

	fileprivate func makeDetailCell(for row: Row) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) ?? UITableViewCell(style: .value1, reuseIdentifier: cellIdentifier)
		cell.textLabel?.text = row.title
		cell.textLabel?.textColor = Color.Grey200
		cell.detailTextLabel?.text = row.value
		cell.detailTextLabel?.textColor = Color.Grey400
		cell.backgroundColor = Color.Grey800
		let selectedBackground = UIView()
		selectedBackground.backgroundColor = Color.Grey700
		cell.selectedBackgroundView = selectedBackground
		let iconSize = CGSize(width: 30, height: 30)
		cell.imageView?.image = row.image.map { row.isSymbol ? $0.padded(to: iconSize) : $0.resized(to: iconSize) }
		cell.imageView?.tintColor = Color.Orange500
		cell.imageView?.layer.magnificationFilter = .nearest
		cell.accessoryType = .disclosureIndicator
		return cell
	}

	override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
		let section = Section(rawValue: indexPath.section)
		return section == .details || section == .about || section == .training
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		if (Section(rawValue: indexPath.section) == .about) {
			switch aboutRows[indexPath.row] {
			case .nickname:
				showNicknameEditor()
			case .gender:
				showGenderPicker()
			case .nature:
				showNaturePicker()
			case .ivs:
				navigationController?.pushViewController(IVEditorVC(container: container, caught: caught), animated: true)
			}
			return
		}
		if (Section(rawValue: indexPath.section) == .training) {
			switch trainingRows[indexPath.row] {
			case .evs:
				navigationController?.pushViewController(EVTrainingVC(container: container, caught: caught), animated: true)
			case .evolve:
				showEvolvePicker()
			}
			return
		}
		guard Section(rawValue: indexPath.section) == .details else { return }
		switch rows[indexPath.row].field {
		case .ball:
			showBallPicker()
		case .game:
			showGamePicker()
		case .method:
			showMethodPicker()
		case .encounters:
			showEncountersEditor()
		case .caughtDate:
			present(CatchDatePickerVC.makeNavigationController(initialDate: caught.caughtDate) { [weak self] date in
				self?.save(.caughtDate(date))
			}, animated: true)
		}
	}

	// MARK: About

	fileprivate func showNicknameEditor() {
		let maximumLength = Catch.maximumNicknameLength
		presentTextInput(title: "Nickname",
						 message: "Up to \(maximumLength) characters. Leave it empty to remove the nickname.",
						 text: caught.nickname,
						 placeholder: caught.pokemonName,
						 isValid: { $0.count <= maximumLength }) { [weak self] nickname in
			self?.save(.nickname(nickname))
		}
	}

	fileprivate func showGenderPicker() {
		let genders = Gender.allCases
		let options = genders.map { PickerOption(title: $0.name, subtitle: $0.symbol) }
		let picker = OptionPickerTVC(title: "Gender", options: options, selectedIndex: caught.gender.flatMap { genders.firstIndex(of: $0) }) { [weak self] index in
			self?.save(.gender(index.map { genders[$0] }))
		}
		navigationController?.pushViewController(picker, animated: true)
	}

	fileprivate func showNaturePicker() {
		let picker = NaturePickerVC(selected: caught.nature) { [weak self] nature in
			self?.save(.nature(nature))
		}
		navigationController?.pushViewController(picker, animated: true)
	}

	// MARK: Evolve

	fileprivate func showEvolvePicker() {
		let targets = details.evolutionTargets
		let items = targets.map { IconGridItem(title: $0.name, image: UIImage(named: $0.name.lowercased())) }
		showPicker(title: "Evolve", caption: "Evolve \(caught.pokemonName) into", items: items, columns: 3, currentIndex: nil) { [weak self] index in
			self?.confirmEvolve(into: targets[index])
		}
	}

	fileprivate func confirmEvolve(into target: NamedPokemon) {
		let alert = UIAlertController(title: "Evolve into \(target.name)?",
									  message: "This \(caught.pokemonName)'s details, EVs and IVs move to \(target.name). You can change it back later.",
									  preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
		alert.addAction(UIAlertAction(title: "Evolve", style: .default) { [weak self] _ in
			self?.evolve(into: target)
		})
		alert.view.tintColor = Color.Orange500
		present(alert, animated: true)
	}

	fileprivate func evolve(into target: NamedPokemon) {
		guard (try? container.evolveCatch.handle(EvolveCatchCommand(catchId: catchId, targetNumber: target.number))) != nil else { return }
		Haptics.playSuccess()
		let previousName = caught.pokemonName
		reloadRows()
		PopupHandler().showPopup(text: "\(previousName) evolved into \(target.name)!")
	}


	fileprivate func showBallPicker() {
		showPicker(title: "Ball", caption: "Caught in", items: ballGrid.items, columns: 4, currentIndex: ballGrid.findIndex(of: caught.caughtBall)) { [weak self] index in
			guard let self = self else { return }
			self.save(.ball(self.ballGrid.ballNames[index]))
		}
	}

	fileprivate func showGamePicker() {
		let games = Games.allCases
		let items = games.map { IconGridItem(title: $0.displayName, image: GamesList.games[$0].flatMap { UIImage(named: $0.coverPokemon) }) }
		showPicker(title: "Game", caption: "Caught in", items: items, columns: 3, currentIndex: games.firstIndex(of: caught.game)) { [weak self] index in
			self?.save(.game(games[index]))
		}
	}

	fileprivate func showMethodPicker() {
		var methods = GamesList.games[caught.game]?.availableMethods ?? [.Encounters]
		if !methods.contains(caught.huntMethod) {
			methods.append(caught.huntMethod)
		}
		let items = methods.map { IconGridItem(title: $0.rawValue, image: UIImage(named: $0.rawValue)) }
		showPicker(title: "Method", caption: "Methods in \(caught.game.displayName)", items: items, columns: 3, currentIndex: methods.firstIndex(of: caught.huntMethod)) { [weak self] index in
			self?.save(.huntMethod(methods[index]))
		}
	}

	fileprivate func showPicker(title: String, caption: String, items: [IconGridItem], columns: Int, currentIndex: Int?, onPick: @escaping (Int) -> Void) {
		let picker = GridPickerVC(title: title, caption: caption, items: items, columns: columns, currentIndex: currentIndex, onPick: onPick)
		navigationController?.pushViewController(picker, animated: true)
	}

	fileprivate func showEncountersEditor() {
		let alert = UIAlertController(title: "Encounters", message: "How many encounters did it take?", preferredStyle: .alert)
		alert.addTextField { [caught] textField in
			textField.text = "\(caught.encounters)"
			textField.keyboardType = .numberPad
		}
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
		alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self, weak alert] _ in
			guard let text = alert?.textFields?.first?.text,
				  let encounters = Int(text.trimmingCharacters(in: .whitespaces)), encounters >= 0 else {
				return
			}
			self?.save(.encounters(encounters))
		})
		present(alert, animated: true)
	}
}

extension UIImage {
	func resized(to size: CGSize) -> UIImage {
		let format = UIGraphicsImageRendererFormat.default()
		let renderer = UIGraphicsImageRenderer(size: size, format: format)
		return renderer.image { context in
			context.cgContext.interpolationQuality = .none
			let scale = min(size.width / self.size.width, size.height / self.size.height)
			let drawSize = CGSize(width: self.size.width * scale, height: self.size.height * scale)
			draw(in: CGRect(x: (size.width - drawSize.width) / 2, y: (size.height - drawSize.height) / 2, width: drawSize.width, height: drawSize.height))
		}
	}
}

extension UIImage {
	func padded(to size: CGSize) -> UIImage {
		let renderer = UIGraphicsImageRenderer(size: size)
		let padded = renderer.image { _ in
			draw(at: CGPoint(x: (size.width - self.size.width) / 2, y: (size.height - self.size.height) / 2))
		}
		return padded.withRenderingMode(.alwaysTemplate)
	}
}

fileprivate class CatchHeroCell: UITableViewCell {
	static let reuseIdentifier = "catchHeroCell"

	fileprivate static let spriteSide: CGFloat = 170
	fileprivate static let glowSide: CGFloat = 280
	fileprivate let glowView = GlowView(intensity: 0.35)
	fileprivate let spriteView = PokemonSpriteView()
	fileprivate let badgeLabel = UILabel(fontSize: 13, weight: .bold, color: Color.Grey900)
	fileprivate let badge = UIView()
	fileprivate let badgeIcon = UIImageView()
	fileprivate let nameLabel = UILabel(fontSize: 30, weight: .bold, color: Color.Grey100)
	fileprivate let speciesLabel = UILabel(fontSize: 17, weight: .semibold, color: Color.Grey300)
	fileprivate let dateLabel = UILabel(fontSize: 15, color: Color.Grey400)
	fileprivate let positionLabel = UILabel(fontSize: 13, weight: .semibold, color: Color.Orange500)

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		backgroundColor = .clear
		selectionStyle = .none


		badge.layer.cornerRadius = 11
		badgeIcon.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 11, weight: .bold)
		let badgeContent = UIStackView(arrangedSubviews: [badgeIcon, badgeLabel])
		badgeContent.spacing = 4
		badgeContent.alignment = .center
		badge.addAutoLayoutSubviews(badgeContent)
		badgeContent.pinEdges(to: badge, insets: UIEdgeInsets(top: 3, left: 9, bottom: 3, right: 10))

		nameLabel.textAlignment = .center
		speciesLabel.textAlignment = .center
		dateLabel.textAlignment = .center
		positionLabel.textAlignment = .center

		let text = UIStackView(arrangedSubviews: [badge, nameLabel, speciesLabel, dateLabel, positionLabel])
		text.axis = .vertical
		text.alignment = .center
		text.spacing = 4
		text.setCustomSpacing(8, after: badge)

		contentView.addAutoLayoutSubviews(glowView, spriteView, text)
		// The glow sits fully inside the cell: the inset grouped table clips anything drawn above a cell's top edge.
		NSLayoutConstraint.activate([
			glowView.topAnchor.constraint(equalTo: contentView.topAnchor),
			glowView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
			glowView.widthAnchor.constraint(equalToConstant: CatchHeroCell.glowSide),
			glowView.heightAnchor.constraint(equalToConstant: CatchHeroCell.glowSide),

			spriteView.centerXAnchor.constraint(equalTo: glowView.centerXAnchor),
			spriteView.centerYAnchor.constraint(equalTo: glowView.centerYAnchor),
			spriteView.widthAnchor.constraint(equalToConstant: CatchHeroCell.spriteSide),
			spriteView.heightAnchor.constraint(equalToConstant: CatchHeroCell.spriteSide),

			text.topAnchor.constraint(equalTo: spriteView.bottomAnchor, constant: 8),
			text.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			text.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
			text.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
		])
		isAccessibilityElement = true
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func configure(pokemonName: String, nickname: String?, genderSymbol: String?, dateText: String, positionText: String?, isFailed: Bool) {
		badge.backgroundColor = isFailed ? Color.Grey600 : Color.Orange500
		badgeLabel.text = isFailed ? "GOT AWAY" : "SHINY"
		badgeLabel.textColor = isFailed ? Color.Grey100 : Color.Grey900
		badgeIcon.image = UIImage(systemName: isFailed ? "wind" : PokemonCell.logCatchSymbol)
		badgeIcon.tintColor = badgeLabel.textColor
		glowView.isHidden = isFailed
		spriteView.setPokemon(named: pokemonName)
		nameLabel.text = [nickname ?? pokemonName, genderSymbol].compactMap { $0 }.joined(separator: " ")
		speciesLabel.text = pokemonName
		speciesLabel.isHidden = nickname == nil
		dateLabel.text = dateText
		positionLabel.text = positionText
		positionLabel.isHidden = positionText == nil
		accessibilityLabel = [nickname, isFailed ? "Shiny \(pokemonName) that got away" : "Shiny \(pokemonName)", dateText, positionText].compactMap { $0 }.joined(separator: ", ")
	}
}

fileprivate class CatchStatsCell: UITableViewCell {
	static let reuseIdentifier = "catchStatsCell"

	fileprivate let encountersValue = UILabel(fontSize: 24, weight: .bold, color: Color.Grey100)
	fileprivate let oddsValue = UILabel(fontSize: 24, weight: .bold, color: Color.Grey100)
	fileprivate let luckLabel = UILabel(fontSize: 15, weight: .medium, color: Color.Orange500, lines: 0)
	fileprivate let luckRow = UIStackView()
	fileprivate let luckBanner = UIView()

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		backgroundColor = .clear
		selectionStyle = .none

		let tiles = UIStackView(arrangedSubviews: [
			CatchStatsCell.makeTile(caption: "ENCOUNTERS", value: encountersValue),
			CatchStatsCell.makeTile(caption: "ODDS", value: oddsValue)
		])
		tiles.distribution = .fillEqually
		tiles.spacing = 12

		let star = UIImageView(image: UIImage.makeSymbol("star.fill", pointSize: 14))
		star.tintColor = Color.Orange500
		star.contentMode = .center
		star.setContentHuggingPriority(.required, for: .horizontal)
		star.setContentCompressionResistancePriority(.required, for: .horizontal)
		star.widthAnchor.constraint(equalToConstant: 18).isActive = true
		luckLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
		luckRow.addArrangedSubview(star)
		luckRow.addArrangedSubview(luckLabel)
		luckRow.spacing = 8
		luckRow.alignment = .center
		luckRow.isLayoutMarginsRelativeArrangement = true
		luckRow.layoutMargins = UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 14)
		luckBanner.backgroundColor = Color.Orange900
		luckBanner.layer.cornerRadius = CornerRadius.standard
		luckBanner.addAutoLayoutSubviews(luckRow)
		luckRow.pinEdges(to: luckBanner)

		let stack = UIStackView(arrangedSubviews: [tiles, luckBanner])
		stack.axis = .vertical
		stack.spacing = 12
		contentView.addAutoLayoutSubviews(stack)
		stack.pinEdges(to: contentView, insets: UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0))
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	fileprivate static func makeTile(caption: String, value: UILabel) -> UIView {
		let tile = UIView()
		tile.backgroundColor = Color.Grey800
		tile.layer.cornerRadius = CornerRadius.standard
		tile.isAccessibilityElement = true
		let captionLabel = UILabel(fontSize: 12, weight: .semibold, color: Color.Grey400)
		captionLabel.text = caption
		value.font = UIFont.monospacedDigitSystemFont(ofSize: 24, weight: .bold)
		value.adjustsFontSizeToFitWidth = true
		value.minimumScaleFactor = 0.6
		let stack = UIStackView(arrangedSubviews: [captionLabel, value])
		stack.axis = .vertical
		stack.spacing = 2
		tile.addAutoLayoutSubviews(stack)
		stack.pinEdges(to: tile, insets: UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 14))
		return tile
	}

	func configure(encounters: String, odds: String, luck: String?) {
		encountersValue.text = encounters
		oddsValue.text = odds
		encountersValue.superview?.superview?.accessibilityLabel = "Encounters \(encounters)"
		oddsValue.superview?.superview?.accessibilityLabel = "Odds \(odds)"
		luckLabel.text = luck
		luckBanner.isHidden = luck == nil
	}
}
