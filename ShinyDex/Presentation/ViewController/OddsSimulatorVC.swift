import UIKit

class OddsSimulatorVC: UIViewController {
    fileprivate static let defaultEncounters = 4096

    fileprivate let container: AppContainer
    fileprivate let scrollView = UIScrollView()
    fileprivate let contentStack = UIStackView()
    fileprivate let gameSettingsContainer = GameSettingsContainer()
    fileprivate let encountersField = UITextField()
    fileprivate let chanceLabel = UILabel(fontSize: 44, weight: .bold, color: Color.Orange500)
    fileprivate let chanceCaptionLabel = UILabel(fontSize: 15, color: Color.Grey400, lines: 0)
    fileprivate let milestonesStack = UIStackView()
    fileprivate let chainNoteLabel = UILabel(fontSize: 13, color: Color.Grey400, lines: 0)
    fileprivate var settings: HuntSettings
    fileprivate var encounters = OddsSimulatorVC.defaultEncounters

    init(container: AppContainer) {
        self.container = container
        settings = container.simulateOdds.handle(SimulateOddsQuery(settings: HuntSettings(game: .Red, generation: 1, huntMethod: .Encounters, isShinyCharmActive: false),
                                                                   encounters: 0,
                                                                   selectingGame: .Scarlet)).settings
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Odds Simulator"
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = Color.Grey900
        setUpGameSettings()
        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.addArrangedSubview(makeChanceSection())
        contentStack.addArrangedSubview(gameSettingsContainer)
        scrollView.keyboardDismissMode = .interactive
        view.addAutoLayoutSubviews(scrollView)
        scrollView.addAutoLayoutSubviews(contentStack)
        scrollView.pinEdges(to: view)
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 8),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -8),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 8),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -8)
        ])
        refresh()
    }

    // MARK: Chance

    fileprivate func makeChanceSection() -> UIView {
        let header = SectionHeaderLabel()
        header.text = "CHANCE OF A SHINY"
        let card = SettingsCard()
        card.stack.isLayoutMarginsRelativeArrangement = true
        card.stack.layoutMargins = UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14)
        card.stack.spacing = 10
        card.stack.addArrangedSubview(makeEncountersRow())
        chanceLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 44, weight: .bold)
        chanceLabel.adjustsFontSizeToFitWidth = true
        chanceLabel.minimumScaleFactor = 0.6
        card.stack.addArrangedSubview(chanceLabel)
        card.stack.addArrangedSubview(chanceCaptionLabel)
        card.stack.setCustomSpacing(16, after: chanceCaptionLabel)
        milestonesStack.axis = .vertical
        milestonesStack.spacing = 8
        card.stack.addArrangedSubview(milestonesStack)
        card.stack.addArrangedSubview(chainNoteLabel)

        let stack = UIStackView(arrangedSubviews: [header, card])
        stack.axis = .vertical
        stack.spacing = 6
        let wrapper = UIView()
        wrapper.addAutoLayoutSubviews(stack)
        stack.pinEdges(to: wrapper, insets: UIEdgeInsets(top: 8, left: 8, bottom: 0, right: 8))
        return wrapper
    }

    fileprivate func makeEncountersRow() -> UIView {
        let label = UILabel(fontSize: 17, weight: .semibold, color: Color.Grey200)
        label.text = "Encounters"
        encountersField.text = String(encounters)
        encountersField.keyboardType = .numberPad
        encountersField.textAlignment = .right
        encountersField.font = UIFont.monospacedDigitSystemFont(ofSize: 20, weight: .semibold)
        encountersField.textColor = Color.Grey100
        encountersField.tintColor = Color.Orange500
        encountersField.accessibilityLabel = "Encounters"
        encountersField.addTarget(self, action: #selector(encountersChanged), for: .editingChanged)
        encountersField.inputAccessoryView = makeKeyboardToolbar()
        encountersField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        let row = UIStackView(arrangedSubviews: [label, encountersField])
        row.spacing = 12
        row.alignment = .center
        return row
    }

    fileprivate func makeKeyboardToolbar() -> UIToolbar {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 44))
        toolbar.tintColor = Color.Orange500
        toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePressed))
        ]
        return toolbar
    }

    fileprivate func makeMilestoneRow(_ milestone: ChanceMilestone) -> UIView {
        let percentLabel = UILabel(fontSize: 15, weight: .semibold, color: Color.Grey200)
        percentLabel.text = "\(milestone.percent)% chance"
        let encountersLabel = UILabel(fontSize: 15, color: Color.Grey300)
        encountersLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 15, weight: .regular)
        encountersLabel.text = milestone.encounters.map { "\($0.grouped) encounters" } ?? "Out of reach"
        encountersLabel.textAlignment = .right
        let row = UIStackView(arrangedSubviews: [percentLabel, encountersLabel])
        row.isAccessibilityElement = true
        row.accessibilityLabel = "\(milestone.percent)% chance by \(encountersLabel.text ?? "")"
        return row
    }

    @objc fileprivate func encountersChanged() {
        encounters = Int(encountersField.text?.filter { $0.isNumber } ?? "") ?? 0
        refresh()
    }

    @objc fileprivate func donePressed() {
        encountersField.resignFirstResponder()
    }

    fileprivate func refresh() {
        let simulation = container.simulateOdds.handle(SimulateOddsQuery(settings: settings, encounters: encounters))
        settings = simulation.settings
        chanceLabel.text = String(format: "%.2f%%", simulation.chance)
        chanceCaptionLabel.text = "within \(simulation.encounters.grouped) encounters at 1/\(simulation.shinyOdds.grouped)"
        chanceLabel.accessibilityLabel = "\(String(format: "%.2f", simulation.chance)) percent chance \(chanceCaptionLabel.text ?? "")"
        milestonesStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        simulation.milestones.map(makeMilestoneRow).forEach(milestonesStack.addArrangedSubview)
        chainNoteLabel.text = simulation.usesChain
            ? "Assumes an unbroken chain, so the odds improve with every encounter in it."
            : nil
        chainNoteLabel.isHidden = chainNoteLabel.text == nil
        gameSettingsContainer.settings = settings
        gameSettingsContainer.setShinyOddsLabelText()
    }

    // MARK: Game settings

    fileprivate func setUpGameSettings() {
        gameSettingsContainer.settings = settings
        gameSettingsContainer.preview = { [weak self] settings in
            guard let self = self else { return HuntSettingsPreview(settings: settings, shinyOdds: 0) }
            let simulation = self.container.simulateOdds.handle(SimulateOddsQuery(settings: settings, encounters: self.encounters))
            return HuntSettingsPreview(settings: simulation.settings, shinyOdds: simulation.shinyOdds)
        }
        gameSettingsContainer.onSettingsChanged = { [weak self] settings in
            self?.settings = settings
            self?.refresh()
        }
        gameSettingsContainer.applyToAllButton.isHidden = true
        gameSettingsContainer.setGame(coverPokemon: GamesList.games[settings.game]?.coverPokemon ?? "charizard")
        gameSettingsContainer.resolveUIObjectsState()
        gameSettingsContainer.setShinyOddsLabelText()
        gameSettingsContainer.explanationLabel.text = "Try any game and method. Nothing here changes your Pokémon or hunts."
        gameSettingsContainer.gameButton.addTarget(self, action: #selector(gameButtonPressed), for: .touchUpInside)
    }

    @objc fileprivate func gameButtonPressed() {
        let selector = GameSelector.make(selectedGame: settings.game) { [weak self] game in
            guard let self = self else { return }
            let simulation = self.container.simulateOdds.handle(SimulateOddsQuery(settings: self.settings, encounters: self.encounters, selectingGame: game))
            self.settings = simulation.settings
            self.gameSettingsContainer.updateUI(updatedSettings: simulation.settings, coverPokemon: GamesList.games[game]?.coverPokemon ?? "charizard")
            self.refresh()
        }
        navigationController?.pushViewController(selector, animated: true)
    }
}
