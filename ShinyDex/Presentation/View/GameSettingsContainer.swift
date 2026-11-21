import UIKit

class GameSettingsContainer: UIView {
    var switchStateService = SwitchStateService()
    var settings: HuntSettings!
    var shinyOdds = 0
    var pokemonName: String?
    var preview: ((HuntSettings) -> HuntSettingsPreview)?
    var onSettingsChanged: ((HuntSettings) -> Void)?
    var gameSettingsCells: [GameSettingsCell]?
    var onApply: ((Int?) -> Void)?

    let shinyCharmCell = GameSettingsCell(title: "Shiny Charm", description: "Available from generation 5 and onwards", icon: PixelArt.makeCenteredImage(named: "Charm"), tag: 3)
    let lureCell = GameSettingsCell(title: "Lure", description: "Only available in Let's Go Pikachu & Eevee.", icon: PixelArt.makeCenteredImage(named: HuntMethod.Lure.rawValue), tag: 8)
    let masudaCell = GameSettingsCell(title: "Masuda", description: "Available from generation 4 and onwards", icon: PixelArt.makeCenteredImage(named: HuntMethod.Masuda.rawValue), tag: 1)
    let pokeradarCell = GameSettingsCell(title: "Pokéradar", description: "Only available in Diamond, Pearl, Platinum, X and Y", icon: PixelArt.makeCenteredImage(named: HuntMethod.Pokeradar.rawValue), tag: 2)
    let genTwoBreedingCell = GameSettingsCell(title: "Gen 2 breeding", description: "Increased shiny odds from breeding shinies are only available in Gold, Silver and Crystal", icon: PixelArt.makeCenteredImage(named: HuntMethod.Gen2Breeding.rawValue), tag: 0)
    let sosChainCell = GameSettingsCell(title: "SOS chaining", description: "Only available in Sun, Moon, Ultra Sun and Ultra Moon", icon: PixelArt.makeCenteredImage(named: HuntMethod.SosChaining.rawValue), tag: 7)
    let chainFishingCell = GameSettingsCell(title: "Chain fishing", description: "Only available in X, Y, Omega Ruby and Alpha Sapphire", icon: PixelArt.makeCenteredImage(named: HuntMethod.ChainFishing.rawValue), tag: 4)
    let dexNavCell = GameSettingsCell(title: "DexNav", description: "Only available in Omega Ruby & Alpha Sapphire", icon: PixelArt.makeCenteredImage(named: HuntMethod.DexNav.rawValue), tag: 5)
    let friendSafariCell = GameSettingsCell(title: "Friend Safari", description: "Only available in X and Y", icon: PixelArt.makeCenteredImage(named: HuntMethod.FriendSafari.rawValue), tag: 6)
    let applyButton = UIButton.make(.tinted, title: "Apply to Other Pokémon", symbolName: "square.stack.3d.down.right", symbolSize: 16)
    let explanationLabel = UILabel(style: .footnote, color: Color.textTertiary, lines: 0)
    fileprivate lazy var explanationFooter: UIView = {
        let wrapper = UIView()
        wrapper.addAutoLayoutSubviews(explanationLabel)
        explanationLabel.pinEdges(to: wrapper, insets: UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14))
        return wrapper
    }()
    let gameButton = UIControl()
    let gameTitle = UILabel(style: .body, weight: .semibold)

    fileprivate let shinyOddsLabel = UILabel(style: .display, weight: .bold, color: Color.accent)
    fileprivate let oddsSummaryLabel = UILabel(style: .subheadline, color: Color.textTertiary, lines: 0)
    fileprivate let gameImageView = UIImageView()
    fileprivate let methodsCard = GameSettingsContainer.makeCardStack()
    fileprivate let unavailableHeader = GameSettingsContainer.makeSectionHeader("")
    fileprivate let unavailableCard = GameSettingsContainer.makeCardStack()
    fileprivate let noMethodsLabel = UILabel(style: .subheadline, color: Color.textTertiary, lines: 0)
    fileprivate var methodCells: [GameSettingsCell] {
        return [genTwoBreedingCell, masudaCell, pokeradarCell, chainFishingCell, friendSafariCell, dexNavCell, sosChainCell, lureCell]
    }

    init() {
        super.init(frame: .zero)
        gameSettingsCells = [genTwoBreedingCell, masudaCell, pokeradarCell, shinyCharmCell, chainFishingCell, dexNavCell, friendSafariCell, sosChainCell, lureCell]
        for cell in gameSettingsCells! {
            cell.actionSwitch.addTarget(self, action: #selector(switchPressed), for: .valueChanged)
        }

        let oddsCard = makeOddsCard()
        let gameCard = GameSettingsContainer.makeCardStack()
        gameCard.stack.addArrangedSubview(makeGameRow())
        let charmCard = GameSettingsContainer.makeCardStack()
        charmCard.stack.addArrangedSubview(shinyCharmCell)

        applyButton.menu = UIMenu(children: [UIDeferredMenuElement.uncached { [weak self] completion in
            completion(self?.makeApplyMenuItems() ?? [])
        }])
        applyButton.showsMenuAsPrimaryAction = true

        let stack = UIStackView(arrangedSubviews: [
            oddsCard,
            GameSettingsContainer.makeSectionHeader("Game"), gameCard,
            GameSettingsContainer.makeSectionHeader("Shiny Charm"), charmCard,
            GameSettingsContainer.makeSectionHeader("Hunt method"), methodsCard,
            unavailableHeader, unavailableCard,
            applyButton, explanationFooter
        ])
        stack.axis = .vertical
        stack.spacing = 6
        stack.setCustomSpacing(20, after: oddsCard)
        stack.setCustomSpacing(20, after: gameCard)
        stack.setCustomSpacing(20, after: charmCard)
        stack.setCustomSpacing(20, after: methodsCard)
        stack.setCustomSpacing(24, after: unavailableCard)
        stack.setCustomSpacing(8, after: applyButton)
        addAutoLayoutSubviews(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24),
            applyButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        setUIColors()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Building blocks

    fileprivate static func makeCardStack() -> SettingsCard {
        return SettingsCard()
    }

    fileprivate static func makeSectionHeader(_ text: String) -> SectionHeaderLabel {
        return SectionHeaderLabel(text: text)
    }

    fileprivate func makeOddsCard() -> UIView {
        let card = UIView()
        card.backgroundColor = Color.surface
        card.layer.cornerRadius = CornerRadius.standard
        card.layer.borderWidth = 1
        card.layer.borderColor = Color.accent.withAlphaComponent(0.35).cgColor

        let sparkle = UIImageView(image: UIImage(systemName: "sparkles") ?? UIImage(systemName: "star.fill"))
        sparkle.tintColor = Color.accent
        sparkle.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 13, weight: .bold)
        let caption = UILabel(style: .footnote, weight: .semibold, color: Color.textTertiary)
        caption.text = "SHINY ODDS"
        let captionRow = UIStackView(arrangedSubviews: [sparkle, caption])
        captionRow.spacing = 6
        captionRow.alignment = .center

        shinyOddsLabel.font = UIFont.make(.display, weight: .bold, monospacedDigits: true)
        shinyOddsLabel.adjustsFontSizeToFitWidth = true
        shinyOddsLabel.minimumScaleFactor = 0.6
        shinyOddsLabel.textAlignment = .center
        oddsSummaryLabel.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [captionRow, shinyOddsLabel, oddsSummaryLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 2
        card.addAutoLayoutSubviews(stack)
        stack.pinEdges(to: card, insets: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
        card.isAccessibilityElement = true
        return card
    }

    fileprivate func makeGameRow() -> UIView {
        gameImageView.contentMode = .scaleAspectFit
        gameImageView.layer.magnificationFilter = .nearest
        gameImageView.isAccessibilityElement = false
        let chevron = UIImageView(image: UIImage.makeSymbol("chevron.right", pointSize: 14, weight: .semibold))
        chevron.tintColor = Color.textQuaternary
        chevron.setContentHuggingPriority(.required, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [gameImageView, gameTitle, chevron])
        row.alignment = .center
        row.spacing = 12
        row.isUserInteractionEnabled = false
        gameButton.addAutoLayoutSubviews(row)
        row.pinEdges(to: gameButton, insets: UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 14))
        NSLayoutConstraint.activate([
            gameImageView.widthAnchor.constraint(equalToConstant: 52),
            gameImageView.heightAnchor.constraint(equalToConstant: 52)
        ])
        gameButton.isAccessibilityElement = true
        gameButton.accessibilityTraits = .button
        gameButton.accessibilityHint = "Choose the game you are hunting in."
        gameButton.addTarget(self, action: #selector(highlightGame), for: [.touchDown, .touchDragEnter])
        gameButton.addTarget(self, action: #selector(unhighlightGame), for: [.touchUpInside, .touchUpOutside, .touchCancel, .touchDragExit])
        return gameButton
    }

    @objc fileprivate func highlightGame() {
        gameButton.backgroundColor = Color.surfaceRaised
    }

    @objc fileprivate func unhighlightGame() {
        UIView.animate(withDuration: 0.2) { self.gameButton.backgroundColor = .clear }
    }

    fileprivate func layOutMethodRows() {
        for card in [methodsCard, unavailableCard] {
            for view in card.stack.arrangedSubviews {
                card.stack.removeArrangedSubview(view)
                view.removeFromSuperview()
            }
        }
        let available = methodCells.filter { $0.actionSwitch.isEnabled }
        let unavailable = methodCells.filter { !$0.actionSwitch.isEnabled }
        for cell in methodCells {
            cell.setAvailable(cell.actionSwitch.isEnabled)
        }
        if (available.isEmpty) {
            noMethodsLabel.text = "\(settings.game.displayName) only has random encounters at base odds."
            let wrapper = UIView()
            wrapper.addAutoLayoutSubviews(noMethodsLabel)
            noMethodsLabel.pinEdges(to: wrapper, insets: UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14))
            methodsCard.stack.addArrangedSubview(wrapper)
        }
        GameSettingsContainer.fill(methodsCard, with: available)
        GameSettingsContainer.fill(unavailableCard, with: unavailable)
        unavailableHeader.text = "NOT AVAILABLE IN \(settings.game.displayName.uppercased())"
        unavailableHeader.isHidden = unavailable.isEmpty
        unavailableCard.isHidden = unavailable.isEmpty
        shinyCharmCell.setAvailable(shinyCharmCell.actionSwitch.isEnabled)
    }

    fileprivate static func fill(_ card: SettingsCard, with cells: [GameSettingsCell]) {
        for (index, cell) in cells.enumerated() {
            if (index > 0 || !card.stack.arrangedSubviews.isEmpty) {
                card.stack.addArrangedSubview(makeSeparator())
            }
            card.stack.addArrangedSubview(cell)
        }
    }

    fileprivate static func makeSeparator() -> UIView {
        let line = UIView()
        let hairline = UIView()
        hairline.backgroundColor = Color.separator
        line.addAutoLayoutSubviews(hairline)
        NSLayoutConstraint.activate([
            line.heightAnchor.constraint(equalToConstant: 1),
            hairline.topAnchor.constraint(equalTo: line.topAnchor),
            hairline.bottomAnchor.constraint(equalTo: line.bottomAnchor),
            hairline.leadingAnchor.constraint(equalTo: line.leadingAnchor, constant: 60),
            hairline.trailingAnchor.constraint(equalTo: line.trailingAnchor)
        ])
        return line
    }

    // MARK: State

    func setGame(coverPokemon: String) {
        gameImageView.image = PixelArt.makeCenteredImage(named: coverPokemon)
        gameTitle.text = settings.game.displayName
        gameButton.accessibilityLabel = "Game, \(settings.game.displayName)"
    }

    func resolveUIObjectsState() {
        genTwoBreedingCell.actionSwitch.isOn = settings.huntMethod == .Gen2Breeding
        masudaCell.actionSwitch.isOn = settings.huntMethod == .Masuda
        shinyCharmCell.actionSwitch.isOn = settings.isShinyCharmActive
        friendSafariCell.actionSwitch.isOn = settings.huntMethod == .FriendSafari
        chainFishingCell.actionSwitch.isOn = settings.huntMethod == .ChainFishing
        sosChainCell.actionSwitch.isOn = settings.huntMethod == .SosChaining
        dexNavCell.actionSwitch.isOn = settings.huntMethod == .DexNav
        lureCell.actionSwitch.isOn = settings.huntMethod == .Lure

        setAllImageViewAlphas()
        resolveSwitchStates()
        layOutMethodRows()
    }

    func setShinyOddsLabelText() {
        if let preview = preview?(settings) {
            settings = preview.settings
            shinyOdds = preview.shinyOdds
        }
        shinyOddsLabel.text = "1/\(shinyOdds.grouped)"
        var parts = [settings.game.displayName, settings.huntMethod.rawValue]
        if (settings.isShinyCharmActive) {
            parts.append("Shiny Charm")
        }
        oddsSummaryLabel.text = parts.joined(separator: " · ")
        shinyOddsLabel.superview?.superview?.accessibilityLabel = "Shiny odds: 1 in \(shinyOdds.grouped), \(parts.joined(separator: ", "))"
    }

    func setExplanationLabelText() {
        explanationLabel.text = pokemonName.map { "Changes here apply to \($0) straight away. Apply to Other Pokémon gives every Pokémon, or every Pokémon from one region, the same game and hunt settings." }
            ?? "These settings don't change any Pokémon on their own. Apply to Other Pokémon gives every Pokémon, or every Pokémon from one region, this game and these hunt settings."
    }

    func updateUI(updatedSettings: HuntSettings, coverPokemon: String) {
        settings = updatedSettings
        setGame(coverPokemon: coverPokemon)
        resolveUIObjectsState()
        setShinyOddsLabelText()
    }

    fileprivate func setImageViewAlpha(imageView: UIImageView, isSwitchOn: Bool) {
        imageView.alpha = isSwitchOn ? 1.0 : 0.55
    }

    func setUIColors() {
        backgroundColor = .clear
    }

    @objc fileprivate func switchPressed(_ sender: UISwitch) {
        let tag = sender.tag
        var selectedHuntMethod = HuntMethod.Encounters
        var icon = UIImageView()
        var cell = shinyCharmCell
        var callTurnSwitchesOff = true

        if (tag == 0) {
            selectedHuntMethod = .Gen2Breeding
            icon = genTwoBreedingCell.iconImageView
            cell = genTwoBreedingCell
            callTurnSwitchesOff = false
        }
        else if (tag == 1) {
            selectedHuntMethod = .Masuda
            icon = masudaCell.iconImageView
            cell = masudaCell
        }
        else if (tag == 2) {
            selectedHuntMethod = .Pokeradar
            icon = pokeradarCell.iconImageView
            cell = pokeradarCell
        }
        else if (tag == 3) {
            selectedHuntMethod = settings.huntMethod
            settings.isShinyCharmActive = sender.isOn
            setImageViewAlpha(imageView: shinyCharmCell.iconImageView, isSwitchOn: settings.isShinyCharmActive)
            cell = shinyCharmCell
            callTurnSwitchesOff = false
        }
        else if (tag == 4) {
            selectedHuntMethod = .ChainFishing
            icon = chainFishingCell.iconImageView
            cell = chainFishingCell
        }
        else if (tag == 5) {
            selectedHuntMethod = .DexNav
            icon = dexNavCell.iconImageView
            cell = dexNavCell
        }
        else if (tag == 6) {
            selectedHuntMethod = .FriendSafari
            icon = friendSafariCell.iconImageView
            cell = friendSafariCell
        }
        else if (tag == 7) {
            selectedHuntMethod = .SosChaining
            icon = sosChainCell.iconImageView
            cell = sosChainCell
        }
        else if (tag == 8) {
            selectedHuntMethod = .Lure
            icon = lureCell.iconImageView
            cell = lureCell
            callTurnSwitchesOff = false
        }
        let activeHuntMethod = sender.isOn || sender.tag == 3 ? selectedHuntMethod : .Encounters
        settings.huntMethod = activeHuntMethod
        setImageViewAlpha(imageView: icon, isSwitchOn: settings.huntMethod == selectedHuntMethod)
        if (callTurnSwitchesOff) {
            turnSwitchesOff(enabledCell: cell, huntMethod: settings.huntMethod)
        }
        setShinyOddsLabelText()
        saveIfReal()
    }

    fileprivate func saveIfReal() {
        onSettingsChanged?(settings)
    }

    fileprivate func setAllImageViewAlphas() {
        setImageViewAlpha(imageView: shinyCharmCell.iconImageView, isSwitchOn: settings.isShinyCharmActive)
        setImageViewAlpha(imageView: genTwoBreedingCell.iconImageView, isSwitchOn: settings.huntMethod == .Gen2Breeding)
        setImageViewAlpha(imageView: masudaCell.iconImageView, isSwitchOn: settings.huntMethod == .Masuda)
        setImageViewAlpha(imageView: pokeradarCell.iconImageView, isSwitchOn: settings.huntMethod == .Pokeradar)
        setImageViewAlpha(imageView: chainFishingCell.iconImageView, isSwitchOn: settings.huntMethod == .ChainFishing)
        setImageViewAlpha(imageView: dexNavCell.iconImageView, isSwitchOn: settings.huntMethod == .DexNav)
        setImageViewAlpha(imageView: friendSafariCell.iconImageView, isSwitchOn: settings.huntMethod == .FriendSafari)
        setImageViewAlpha(imageView: dexNavCell.iconImageView, isSwitchOn: settings.huntMethod == .DexNav)
        setImageViewAlpha(imageView: sosChainCell.iconImageView, isSwitchOn: settings.huntMethod == .SosChaining)
        setImageViewAlpha(imageView: lureCell.iconImageView, isSwitchOn: settings.huntMethod == .Lure)
    }

    fileprivate func turnSwitchesOff(enabledCell: GameSettingsCell, huntMethod: HuntMethod) {
        gameSettingsCells!.removeAll{$0 == enabledCell || $0 == shinyCharmCell}
        for cell in gameSettingsCells! {
            setImageViewAlpha(imageView: cell.iconImageView, isSwitchOn: false)
            cell.actionSwitch.isOn = false
        }
        setImageViewAlpha(imageView: shinyCharmCell.iconImageView, isSwitchOn: settings.isShinyCharmActive)
        setImageViewAlpha(imageView: enabledCell.iconImageView, isSwitchOn: enabledCell.actionSwitch.isOn)
        gameSettingsCells!.append(enabledCell)
        gameSettingsCells!.append(shinyCharmCell)
        setShinyOddsLabelText()
        saveIfReal()
    }

    fileprivate func resolveSwitchStates() {
        switchStateService.resolveShinyCharmSwitchState(settings: settings, shinyCharmSwitch: shinyCharmCell.actionSwitch)
        switchStateService.resolveHuntMethodSwitchState(settings: settings, huntMethodSwitch: lureCell.actionSwitch, huntMethod: .Lure)
        switchStateService.resolveHuntMethodSwitchState(settings: settings, huntMethodSwitch: masudaCell.actionSwitch, huntMethod: .Masuda)
        switchStateService.resolveHuntMethodSwitchState(settings: settings, huntMethodSwitch: genTwoBreedingCell.actionSwitch, huntMethod: .Gen2Breeding)
        switchStateService.resolveHuntMethodSwitchState(settings: settings, huntMethodSwitch: friendSafariCell.actionSwitch, huntMethod: .FriendSafari)
        switchStateService.resolveHuntMethodSwitchState(settings: settings, huntMethodSwitch: sosChainCell.actionSwitch, huntMethod: .SosChaining)
        switchStateService.resolveHuntMethodSwitchState(settings: settings, huntMethodSwitch: chainFishingCell.actionSwitch, huntMethod: .ChainFishing)
        switchStateService.resolveHuntMethodSwitchState(settings: settings, huntMethodSwitch: pokeradarCell.actionSwitch, huntMethod: .Pokeradar)
        switchStateService.resolveHuntMethodSwitchState(settings: settings, huntMethodSwitch: dexNavCell.actionSwitch, huntMethod: .DexNav)
    }

    fileprivate func makeApplyMenuItems() -> [UIMenuElement] {
        let gameGeneration = GamesList.games[settings.game]?.generation ?? 0
        let all = UIAction(title: "All Pokémon", image: UIImage(systemName: "square.stack.3d.down.right")) { [weak self] _ in self?.onApply?(nil) }
        let regions = PokedexRegions.all.map { region -> UIAction in
            let action = UIAction(title: "\(TextResolver().getGenTitle(gen: region)) Pokémon") { [weak self] _ in self?.onApply?(region) }
            if PokedexRegions.findGeneration(ofRegion: region) > gameGeneration {
                action.attributes = .disabled
                action.subtitle = "Not in \(settings.game.displayName)"
            }
            return action
        }
        return [all, UIMenu(title: "Region", options: .displayInline, children: regions)]
    }
}

class SettingsCard: UIView {
    let stack = UIStackView()

    init() {
        super.init(frame: .zero)
        backgroundColor = Color.surface
        layer.cornerRadius = CornerRadius.standard
        clipsToBounds = true
        stack.axis = .vertical
        addAutoLayoutSubviews(stack)
        stack.pinEdges(to: self)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
