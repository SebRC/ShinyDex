import UIKit
import FLAnimatedImage

class ShinyTrackerVC: UIViewController {
	fileprivate let plusButton = UIButton(type: .system)
	fileprivate let minusButton = UIButton(type: .system)
	fileprivate let buttonStrip = ButtonStrip()
	fileprivate let animatedImageView = FLAnimatedImageView()
	fileprivate let heroView = UIView()
	fileprivate let methodIconView = UIImageView()
	fileprivate let encountersCaptionLabel = UILabel(fontSize: 13, weight: .semibold, color: Color.Grey400)
	fileprivate let encountersValueLabel = UILabel(fontSize: 56, weight: .bold, color: Color.Grey100)
	fileprivate let encountersDetailLabel = UILabel(fontSize: 15, color: Color.Grey400)
	fileprivate let caughtBallView = UIImageView()
	fileprivate let caughtLabel = UILabel(fontSize: 13, weight: .semibold, color: Color.Orange500)
	fileprivate let caughtRow = UIStackView()
	fileprivate let catchService = CatchService()
	fileprivate let oddsTile = StatTileView(caption: "Shiny odds")
	fileprivate let probabilityTile = StatTileView(caption: "Chance so far")
	fileprivate var addToHuntButton: UIBarButtonItem!

	var pokemon: Pokemon!
	let probabilityService = ProbabilityService()
	let oddsService = OddsService()
	var probability: Double?
	var methodDecrement = 0
	let popupHandler = PopupHandler()
	var pokemonService = PokemonService()
	var huntService = HuntService()
	var textResolver = TextResolver()

	init(pokemon: Pokemon) {
		self.pokemon = pokemon
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		layOutViews()
		setUpNavigationItems()
		setGif()
		setMethodDecrement()
		resolveEncounterDetails()
		setCaughtStatus()
		setMethodImage()
		setIncrementImage()
		setButtonActions()
		setOddsLabelText()
		setAccessibilityLabels()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		setCaughtStatus()
	}

	fileprivate func layOutViews() {
		title = pokemon.name
		navigationItem.largeTitleDisplayMode = .never
		view.backgroundColor = Color.Grey900
		animatedImageView.contentMode = .scaleAspectFit
		animatedImageView.isAccessibilityElement = false
		animatedImageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
		animatedImageView.setContentHuggingPriority(.defaultLow, for: .vertical)

		setUpHeroView()
		setUpCounterButtons()

		let stats = UIStackView(arrangedSubviews: [oddsTile, probabilityTile])
		stats.distribution = .fillEqually
		stats.spacing = 12

		let counter = UIStackView(arrangedSubviews: [minusButton, plusButton])
		counter.spacing = 12

		view.addAutoLayoutSubviews(heroView, stats, animatedImageView, buttonStrip, counter)
		let safeArea = view.safeAreaLayoutGuide
		NSLayoutConstraint.activate([
			heroView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 12),
			stats.topAnchor.constraint(equalTo: heroView.bottomAnchor, constant: 12),

			animatedImageView.topAnchor.constraint(equalTo: stats.bottomAnchor, constant: 12),
			animatedImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			animatedImageView.widthAnchor.constraint(lessThanOrEqualToConstant: 220),
			animatedImageView.widthAnchor.constraint(lessThanOrEqualTo: safeArea.widthAnchor, constant: -32),

			buttonStrip.topAnchor.constraint(equalTo: animatedImageView.bottomAnchor, constant: 12),
			counter.topAnchor.constraint(equalTo: buttonStrip.bottomAnchor, constant: 12),
			counter.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -12),
			counter.heightAnchor.constraint(equalToConstant: 76),
			minusButton.widthAnchor.constraint(equalToConstant: 88)
		])
		for row in [heroView, stats, buttonStrip, counter] as [UIView] {
			NSLayoutConstraint.activate([
				row.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
				row.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16)
			])
		}
	}

	fileprivate func setUpHeroView() {
		heroView.backgroundColor = Color.Grey800
		heroView.layer.cornerRadius = CornerRadius.standard
		methodIconView.contentMode = .scaleAspectFit
		methodIconView.layer.magnificationFilter = .nearest
		encountersValueLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 56, weight: .bold)
		encountersValueLabel.adjustsFontSizeToFitWidth = true
		encountersValueLabel.minimumScaleFactor = 0.5
		encountersValueLabel.textAlignment = .center
		encountersDetailLabel.textAlignment = .center

		let captionRow = UIStackView(arrangedSubviews: [methodIconView, encountersCaptionLabel])
		captionRow.spacing = 6
		captionRow.alignment = .center
		caughtBallView.contentMode = .scaleAspectFit
		caughtBallView.layer.magnificationFilter = .nearest
		caughtRow.addArrangedSubview(caughtBallView)
		caughtRow.addArrangedSubview(caughtLabel)
		caughtRow.spacing = 4
		caughtRow.alignment = .center
		caughtBallView.widthAnchor.constraint(equalToConstant: 18).isActive = true
		caughtBallView.heightAnchor.constraint(equalToConstant: 18).isActive = true

		let stack = UIStackView(arrangedSubviews: [captionRow, encountersValueLabel, encountersDetailLabel, caughtRow])
		stack.axis = .vertical
		stack.alignment = .center
		stack.spacing = 0
		heroView.addAutoLayoutSubviews(stack)
		stack.pinEdges(to: heroView, insets: UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16))
		NSLayoutConstraint.activate([
			methodIconView.widthAnchor.constraint(equalToConstant: 24),
			methodIconView.heightAnchor.constraint(equalToConstant: 24)
		])
		heroView.isAccessibilityElement = true
	}

	fileprivate func setUpCounterButtons() {
		minusButton.backgroundColor = Color.Grey800
		minusButton.layer.cornerRadius = 20
		minusButton.tintColor = Color.Grey200
		minusButton.setImage(UIImage.symbol("minus", pointSize: 28, weight: .bold), for: .normal)

		plusButton.backgroundColor = Color.Orange500
		plusButton.layer.cornerRadius = 20
		plusButton.tintColor = Color.Grey900
		plusButton.setImage(UIImage.symbol("plus", pointSize: 26, weight: .bold), for: .normal)
		plusButton.titleLabel?.font = UIFont.monospacedDigitSystemFont(ofSize: 30, weight: .bold)
		plusButton.setTitleColor(Color.Grey900, for: .normal)
		plusButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
		plusButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: -4)
	}

	fileprivate func setUpNavigationItems() {
		addToHuntButton = UIBarButtonItem(image: UIImage(systemName: "text.badge.plus"), style: .plain, target: self, action: #selector(addToHuntPressed))
		addToHuntButton.isEnabled = addToHuntButtonIsEnabled()
		let catchesButton = UIBarButtonItem(image: UIImage(systemName: "list.bullet"), style: .plain, target: self, action: #selector(catchesButtonPressed))
		catchesButton.accessibilityLabel = "Catches"
		navigationItem.rightBarButtonItems = [addToHuntButton, catchesButton]
	}

	fileprivate func setAccessibilityLabels() {
		minusButton.accessibilityLabel = "Remove an encounter"
		addToHuntButton.accessibilityLabel = "Add to hunt"
		buttonStrip.updateEncountersButton.accessibilityLabel = "Set encounters"
		buttonStrip.methodButton.accessibilityLabel = "Game and hunt method"
		buttonStrip.pokeballButton.accessibilityLabel = "Log a catch"
		buttonStrip.locationButton.accessibilityLabel = "Where to find \(pokemon.name)"
		updateIncrementAccessibility()
	}

	fileprivate func updateIncrementAccessibility() {
		let increment = pokemon.increment
		plusButton.accessibilityLabel = increment == 1 ? "Add an encounter" : "Add \(increment) encounters"
		buttonStrip.incrementButton.accessibilityLabel = "Encounters per tap"
		buttonStrip.incrementButton.accessibilityValue = "\(increment)"
	}

	@objc fileprivate func catchesButtonPressed() {
		navigationController?.pushViewController(CatchesTVC(pokemon: pokemon), animated: true)
	}

	fileprivate func setMethodDecrement() {
		if (pokemon.huntMethod == .SosChaining || pokemon.huntMethod == .Lure || pokemon.generation == 0) {
			methodDecrement = 30
		}
		else if (pokemon.huntMethod == .ChainFishing) {
			methodDecrement = 20
		}
		else if (pokemon.huntMethod == .Pokeradar) {
			methodDecrement = 40
		}
		else if (pokemon.huntMethod == .DexNav) {
			methodDecrement = 999
		}
		else {
			methodDecrement = 0
		}
	}

	fileprivate func setCaughtStatus() {
		let catchCount = catchService.getCatches(for: pokemon).count
		caughtBallView.image = UIImage(named: pokemon.caughtBall)
		caughtLabel.text = catchCount == 1 ? "Caught" : "Caught ×\(catchCount)"
		caughtRow.isHidden = catchCount == 0
		buttonStrip.pokeballButton.accessibilityValue = catchCount == 0 ? "Not caught yet" : caughtLabel.text
	}

	fileprivate func setMethodImage() {
		let image = getMethodImage()
		methodIconView.image = image
		buttonStrip.methodButton.iconView.image = image
	}

	fileprivate func getMethodImage() -> UIImage? {
		let huntMethod = pokemon.huntMethod
		let canBeCombinedWithCharm = huntMethod != .Gen2Breeding && huntMethod != .Pokeradar
		if (pokemon.isShinyCharmActive && canBeCombinedWithCharm) {
			return UIImage(named: "\(huntMethod.rawValue) + Charm")
		}
		return UIImage(named: huntMethod.rawValue)
	}

	fileprivate func setGif() {
		if let gifAsset = NSDataAsset(name: "\(pokemon.name)") {
			animatedImageView.animatedImage = FLAnimatedImage(animatedGIFData: gifAsset.data)
		}
	}

	fileprivate func setButtonActions() {
		plusButton.addTarget(self, action: #selector(plusPressed), for: .touchUpInside)
		minusButton.addTarget(self, action: #selector(minusPressed), for: .touchUpInside)
		buttonStrip.updateEncountersButton.addTarget(self, action: #selector(updateEncountersPressed), for: .touchUpInside)
		buttonStrip.incrementButton.addTarget(self, action: #selector(incrementButtonPressed), for: .touchUpInside)
		buttonStrip.methodButton.addTarget(self, action: #selector(infoButtonPressed), for: .touchUpInside)
		buttonStrip.pokeballButton.addTarget(self, action: #selector(changeCaughtButtonPressed), for: .touchUpInside)
		buttonStrip.locationButton.addTarget(self, action: #selector(locationButtonPressed), for: .touchUpInside)
	}

	fileprivate func resolveEncounterDetails() {
		setProbability()
		setProbabilityLabelText()
		setEncountersText(textResolver.getEncountersLabelText(pokemon: pokemon, methodDecrement: methodDecrement))
		setOddsLabelText()
		minusButton.isEnabled = minusButtonIsEnabled()
	}

	fileprivate func setProbability() {
		pokemon.shinyOdds = oddsService.getShinyOdds(pokemon: pokemon)
		probability = probabilityService.getProbability(encounters: pokemon.encounters - methodDecrement, shinyOdds: pokemon.shinyOdds)
	}

	fileprivate func setEncountersText(_ text: String) {
		let lines = text.components(separatedBy: "\n").map { line -> (label: String, value: String) in
			let parts = line.components(separatedBy: ": ")
			guard parts.count == 2 else { return ("Encounters", line) }
			let value = Int(parts[1]).map { $0.grouped } ?? parts[1]
			return (parts[0], value)
		}
		guard let primary = lines.first else { return }
		encountersCaptionLabel.text = primary.label.uppercased()
		encountersValueLabel.text = primary.value
		let details = lines.dropFirst().map { "\($0.label): \($0.value)" }
		encountersDetailLabel.text = details.joined(separator: " · ")
		encountersDetailLabel.isHidden = details.isEmpty
		heroView.accessibilityLabel = ([primary] + Array(lines.dropFirst())).map { "\($0.label) \($0.value)" }.joined(separator: ", ")
	}

	fileprivate func setProbabilityLabelText() {
		let text = probabilityService.getProbabilityText(probability: probability!, pokemon: pokemon, methodDecrement: methodDecrement)
		if (text.hasPrefix("Probability")) {
			probabilityTile.setValue(String(format: "%.2f%%", probability!))
		}
		else {
			probabilityTile.setMessage(text)
		}
	}

	fileprivate func setOddsLabelText() {
		oddsTile.setValue("1/\(pokemon.shinyOdds.grouped)")
		oddsTile.accessibilityValue = "1 in \(pokemon.shinyOdds.grouped)"
	}

	fileprivate func minusButtonIsEnabled() -> Bool {
		return pokemon.encounters != 0
	}

	fileprivate func addToHuntButtonIsEnabled() -> Bool {
		return !pokemon.isBeingHunted
	}

	@objc fileprivate func plusPressed() {
		Haptics.tap()
		pokemon.encounters += pokemon.increment
		resolveEncounterDetails()
		pokemonService.save(pokemon: pokemon)
	}

	@objc fileprivate func minusPressed() {
		guard pokemon.encounters > 0 else { return }
		Haptics.tap()
		pokemon.encounters -= 1
		resolveEncounterDetails()
		pokemonService.save(pokemon: pokemon)
	}

	@objc fileprivate func addToHuntPressed() {
		let picker = HuntPickerModalVC(pokemon: pokemon) { [weak self] huntName in
			guard let self = self else { return }
			self.addToHuntButton.isEnabled = self.addToHuntButtonIsEnabled()
			self.popupHandler.showPopup(text: "\(self.pokemon.name) was added to \(huntName).")
		}
		present(picker.inSheet(), animated: true)
	}

	@objc fileprivate func infoButtonPressed() {
		let gameSettings = GameSettingsModalVC(pokemon: pokemon) { [weak self] in
			self?.gameSettingsChanged()
		}
		present(gameSettings.inSheet(), animated: true)
	}

	@objc fileprivate func updateEncountersPressed() {
		let maximum = 500000
		presentTextInput(title: "Set encounters",
						 message: "Enter a number from 0 to \(maximum.grouped).",
						 text: "\(pokemon.encounters)",
						 placeholder: "Encounters",
						 keyboardType: .numberPad,
						 isValid: { Int($0).map { (0...maximum).contains($0) } ?? false }) { [weak self] value in
			guard let self = self, let encounters = Int(value) else { return }
			self.pokemon.encounters = encounters
			self.pokemonService.save(pokemon: self.pokemon)
			self.resolveEncounterDetails()
		}
	}

	@objc fileprivate func incrementButtonPressed() {
		let incrementPicker = IncrementVC(pokemon: pokemon) { [weak self] in
			self?.setIncrementImage()
		}
		present(incrementPicker.inSheet(), animated: true)
	}

	@objc fileprivate func changeCaughtButtonPressed() {
		let picker = PokeballModalVC(pokemon: pokemon) { [weak self] _ in
			self?.setCaughtStatus()
		}
		present(picker.inSheet(), animated: true)
	}

	@objc fileprivate func locationButtonPressed() {
		navigationController?.pushViewController(LocationVC(pokemon: pokemon), animated: true)
	}

	fileprivate func gameSettingsChanged() {
		setMethodImage()
		setMethodDecrement()
		resolveEncounterDetails()
		setOddsLabelText()
	}

	fileprivate func setIncrementImage() {
		let symbolName = pokemon.increment > 50 ? "plus.circle" : "\(pokemon.increment).circle"
		buttonStrip.incrementButton.iconView.image = UIImage.symbol(symbolName, pointSize: ButtonStrip.symbolPointSize, weight: .medium)
		plusButton.setTitle("\(pokemon.increment)", for: .normal)
		updateIncrementAccessibility()
	}
}

fileprivate class StatTileView: UIView {
	fileprivate let captionLabel = UILabel(fontSize: 13, weight: .semibold, color: Color.Grey400)
	fileprivate let valueLabel = UILabel(fontSize: 22, weight: .semibold, lines: 2)

	init(caption: String) {
		super.init(frame: .zero)
		backgroundColor = Color.Grey800
		layer.cornerRadius = CornerRadius.standard
		isAccessibilityElement = true
		accessibilityLabel = caption
		captionLabel.text = caption.uppercased()
		valueLabel.adjustsFontSizeToFitWidth = true
		valueLabel.minimumScaleFactor = 0.6

		let stack = UIStackView(arrangedSubviews: [captionLabel, valueLabel])
		stack.axis = .vertical
		stack.spacing = 2
		addAutoLayoutSubviews(stack)
		stack.pinEdges(to: self, insets: UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 14))
		heightAnchor.constraint(greaterThanOrEqualToConstant: 68).isActive = true
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func setValue(_ value: String) {
		valueLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 22, weight: .semibold)
		valueLabel.textColor = Color.Grey100
		valueLabel.text = value
		accessibilityValue = value
	}

	func setMessage(_ message: String) {
		valueLabel.font = UIFont.systemFont(ofSize: 14)
		valueLabel.textColor = Color.Grey300
		valueLabel.text = message
		accessibilityValue = message
	}
}
