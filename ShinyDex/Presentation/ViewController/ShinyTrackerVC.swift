import UIKit

class ShinyTrackerVC: UIViewController {
    fileprivate let plusButton = UIButton(type: .system)
    fileprivate let minusButton = UIButton(type: .system)
    fileprivate let buttonStrip = ButtonStrip()
    fileprivate let spriteView = PokemonSpriteView()
    fileprivate let heroView = UIView()
    fileprivate let methodIconView = UIImageView()
    fileprivate let encountersCaptionLabel = UILabel(fontSize: 13, weight: .semibold, color: Color.Grey400)
    fileprivate let encountersValueLabel = UILabel(fontSize: 56, weight: .bold, color: Color.Grey100)
    fileprivate let encountersDetailLabel = UILabel(fontSize: 15, color: Color.Grey400)
    fileprivate let caughtBallView = UIImageView()
    fileprivate let caughtLabel = UILabel(fontSize: 13, weight: .semibold, color: Color.Orange500)
    fileprivate let caughtRow = UIStackView()
    fileprivate let oddsTile = StatTileView(caption: "Shiny odds")
    fileprivate let probabilityTile = StatTileView(caption: "Chance so far")
    fileprivate var addToHuntButton: UIBarButtonItem!
    fileprivate var hasAppeared = false

    fileprivate let container: AppContainer
    fileprivate var pokemon: PokemonDetails
    let popupHandler = PopupHandler()
    var textResolver = TextResolver()

    init?(container: AppContainer, number: Int) {
        guard let pokemon = container.getPokemonDetails.handle(GetPokemonDetailsQuery(number: number)) else { return nil }
        self.container = container
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
        setSprite()
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
        reloadPokemon()
        setCaughtStatus()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (!hasAppeared && !UIAccessibility.isReduceMotionEnabled) {
            spriteView.playAnimationOnce()
        }
        hasAppeared = true
    }

    fileprivate func reloadPokemon() {
        if let updated = container.getPokemonDetails.handle(GetPokemonDetailsQuery(number: pokemon.number)) {
            pokemon = updated
        }
    }

    fileprivate func layOutViews() {
        title = pokemon.name
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = Color.Grey900

        setUpHeroView()
        setUpCounterButtons()

        let stats = UIStackView(arrangedSubviews: [oddsTile, probabilityTile])
        stats.distribution = .fillEqually
        stats.spacing = 12

        let counter = UIStackView(arrangedSubviews: [minusButton, plusButton])
        counter.spacing = 12

        view.addAutoLayoutSubviews(heroView, stats, spriteView, buttonStrip, counter)
        let safeArea = view.safeAreaLayoutGuide
        let preferredSpriteWidth = spriteView.widthAnchor.constraint(equalToConstant: 220)
        preferredSpriteWidth.priority = .defaultHigh
        // The sprite view has no intrinsic size, so without this the button strip would stretch into the leftover height instead.
        let spriteFillsRemainingHeight = spriteView.heightAnchor.constraint(equalToConstant: 10_000)
        spriteFillsRemainingHeight.priority = UILayoutPriority(500)
        NSLayoutConstraint.activate([
            preferredSpriteWidth,
            spriteFillsRemainingHeight,
            heroView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 12),
            stats.topAnchor.constraint(equalTo: heroView.bottomAnchor, constant: 12),

            spriteView.topAnchor.constraint(equalTo: stats.bottomAnchor, constant: 12),
            spriteView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spriteView.widthAnchor.constraint(lessThanOrEqualTo: safeArea.widthAnchor, constant: -32),

            buttonStrip.topAnchor.constraint(equalTo: spriteView.bottomAnchor, constant: 12),
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
        minusButton.setImage(UIImage.makeSymbol("minus", pointSize: 28, weight: .bold), for: .normal)

        plusButton.backgroundColor = Color.Orange500
        plusButton.layer.cornerRadius = 20
        plusButton.tintColor = Color.Grey900
        plusButton.setImage(UIImage.makeSymbol("plus", pointSize: 26, weight: .bold), for: .normal)
        plusButton.titleLabel?.font = UIFont.monospacedDigitSystemFont(ofSize: 30, weight: .bold)
        plusButton.setTitleColor(Color.Grey900, for: .normal)
        plusButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
        plusButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: -4)
    }

    fileprivate func setUpNavigationItems() {
        addToHuntButton = UIBarButtonItem(image: UIImage(systemName: "text.badge.plus"), style: .plain, target: self, action: #selector(addToHuntPressed))
        addToHuntButton.isEnabled = isAddToHuntButtonEnabled()
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
        navigationController?.pushViewController(CatchesTVC(container: container, number: pokemon.number, pokemonName: pokemon.name), animated: true)
    }

    fileprivate func setCaughtStatus() {
        let catchCount = pokemon.catchCount
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
        let huntMethod = pokemon.settings.huntMethod
        let canBeCombinedWithCharm = huntMethod != .Gen2Breeding && huntMethod != .Pokeradar
        if (pokemon.settings.isShinyCharmActive && canBeCombinedWithCharm) {
            return UIImage(named: "\(huntMethod.rawValue) + Charm")
        }
        return UIImage(named: huntMethod.rawValue)
    }

    fileprivate func setSprite() {
        spriteView.setPokemon(named: pokemon.name)
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
        setProbabilityLabelText()
        setEncountersText(textResolver.getEncountersLabelText(pokemon: pokemon))
        setOddsLabelText()
        minusButton.isEnabled = isMinusButtonEnabled()
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
        let text = textResolver.getProbabilityText(pokemon: pokemon)
        if (text.hasPrefix("Probability")) {
            probabilityTile.setValue(String(format: "%.2f%%", pokemon.probability))
        }
        else {
            probabilityTile.setMessage(text)
        }
    }

    fileprivate func setOddsLabelText() {
        oddsTile.setValue("1/\(pokemon.shinyOdds.grouped)")
        oddsTile.accessibilityValue = "1 in \(pokemon.shinyOdds.grouped)"
    }

    fileprivate func isMinusButtonEnabled() -> Bool {
        return pokemon.encounters != 0
    }

    fileprivate func isAddToHuntButtonEnabled() -> Bool {
        return !pokemon.isBeingHunted
    }

    @objc fileprivate func plusPressed() {
        Haptics.tap()
        changeEncounters(.increment)
    }

    @objc fileprivate func minusPressed() {
        guard pokemon.encounters > 0 else { return }
        Haptics.tap()
        changeEncounters(.decrement)
    }

    fileprivate func changeEncounters(_ change: ChangeEncountersCommand.Change) {
        container.changeEncounters.handle(ChangeEncountersCommand(number: pokemon.number, change: change))
        reloadPokemon()
        resolveEncounterDetails()
    }

    @objc fileprivate func addToHuntPressed() {
        let picker = HuntPickerModalVC(container: container, number: pokemon.number, pokemonName: pokemon.name) { [weak self] huntName in
            guard let self = self else { return }
            self.reloadPokemon()
            self.addToHuntButton.isEnabled = self.isAddToHuntButtonEnabled()
            self.popupHandler.showPopup(text: "\(self.pokemon.name) was added to \(huntName).")
        }
        present(picker.wrapInSheet(), animated: true)
    }

    @objc fileprivate func infoButtonPressed() {
        let gameSettings = GameSettingsModalVC(container: container, pokemon: pokemon) { [weak self] in
            self?.gameSettingsChanged()
        }
        present(gameSettings.wrapInSheet(), animated: true)
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
            self.changeEncounters(.set(encounters))
        }
    }

    @objc fileprivate func incrementButtonPressed() {
        let incrementPicker = IncrementVC(container: container, number: pokemon.number, increment: pokemon.increment) { [weak self] in
            self?.reloadPokemon()
            self?.setIncrementImage()
        }
        present(incrementPicker.wrapInSheet(), animated: true)
    }

    @objc fileprivate func changeCaughtButtonPressed() {
        let picker = PokeballModalVC(container: container, number: pokemon.number, pokemonName: pokemon.name) { [weak self] _ in
            self?.reloadPokemon()
            self?.setCaughtStatus()
        }
        present(picker.wrapInSheet(), animated: true)
    }

    @objc fileprivate func locationButtonPressed() {
        guard let url = container.getLocationLink.handle(GetLocationLinkQuery(number: pokemon.number)) else { return }
        navigationController?.pushViewController(LocationVC(url: url), animated: true)
    }

    fileprivate func gameSettingsChanged() {
        reloadPokemon()
        setMethodImage()
        resolveEncounterDetails()
        setOddsLabelText()
    }

    fileprivate func setIncrementImage() {
        let symbolName = pokemon.increment > 50 ? "plus.circle" : "\(pokemon.increment).circle"
        buttonStrip.incrementButton.iconView.image = UIImage.makeSymbol(symbolName, pointSize: ButtonStrip.symbolPointSize, weight: .medium)
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
