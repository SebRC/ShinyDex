import UIKit

class JourneysTVC: UITableViewController {
    fileprivate enum Section: Int, CaseIterable {
        case nextHunt
        case journeys
    }

    fileprivate let container: AppContainer
    fileprivate var journeys = [JourneySummary]()
    fileprivate var nextHunt: NextHunt?

    init(container: AppContainer) {
        self.container = container
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
        navigationItem.rightBarButtonItems = [addButton, makeSuggestionModeButton()]
        tableView.backgroundColor = Color.background
        tableView.separatorColor = Color.separator
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 110
        tableView.register(JourneyCell.self, forCellReuseIdentifier: JourneyCell.reuseIdentifier)
        tableView.register(NextHuntCell.self, forCellReuseIdentifier: NextHuntCell.reuseIdentifier)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadJourneys()
    }

    fileprivate func makeSuggestionModeButton() -> UIBarButtonItem {
        return HuntSuggestionModeMenu.makeButton(selected: container.getHuntSuggestionMode.handle(GetHuntSuggestionModeQuery())) { [weak self] mode in
            guard let self = self else { return }
            self.container.chooseHuntSuggestionMode.handle(ChooseHuntSuggestionModeCommand(mode: mode))
            self.reloadJourneys()
        }
    }

    fileprivate func reloadJourneys() {
        journeys = container.getJourneys.handle(GetJourneysQuery())
        nextHunt = container.getNextHunt.handle(GetNextHuntQuery())
        navigationItem.rightBarButtonItems?[1] = makeSuggestionModeButton()
        tableView.reloadData()
        tableView.backgroundView = journeys.isEmpty
            ? EmptyStateView(symbolName: "map.fill",
                             title: "No journeys yet",
                             message: "Plan a shiny badge quest, a dream team or any other goal, and tick off each Pokémon as you catch it.")
            : nil
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section) {
        case .nextHunt: return nextHunt == nil ? 0 : 1
        case .journeys: return journeys.count
        case nil: return 0
        }
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch Section(rawValue: section) {
        case .nextHunt: return SectionHeaderView.make(for: tableView, title: nextHunt == nil ? nil : "Hunt next")
        case .journeys: return SectionHeaderView.make(for: tableView, title: nextHunt == nil || journeys.isEmpty ? nil : "Journeys")
        case nil: return nil
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.tableView(tableView, viewForHeaderInSection: section) == nil ? CGFloat.leastNormalMagnitude : UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if Section(rawValue: indexPath.section) == .nextHunt, let nextHunt = nextHunt {
            let cell = tableView.dequeueReusableCell(withIdentifier: NextHuntCell.reuseIdentifier, for: indexPath) as! NextHuntCell
            cell.configure(nextHunt)
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: JourneyCell.reuseIdentifier, for: indexPath) as! JourneyCell
        let journey = journeys[indexPath.row]
        cell.configure(name: journey.name, caught: journey.caughtCount, members: journey.members, game: journey.game)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if Section(rawValue: indexPath.section) == .nextHunt, let nextHunt = nextHunt {
            openJourney(nextHunt.journeyId)
            return
        }
        openJourney(journeys[indexPath.row].id)
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard Section(rawValue: indexPath.section) == .journeys else { return nil }
        let journey = journeys[indexPath.row]
        let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, done in
            self?.confirmDelete(journey)
            done(false)
        }
        let rename = UIContextualAction(style: .normal, title: "Rename") { [weak self] _, _, done in
            self?.rename(journey)
            done(true)
        }
        rename.backgroundColor = Color.inactive
        return UISwipeActionsConfiguration(actions: [delete, rename])
    }

    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard Section(rawValue: indexPath.section) == .journeys else { return nil }
        let journey = journeys[indexPath.row]
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            UIMenu(title: journey.name, children: [
                UIAction(title: "Rename", image: UIImage(systemName: "pencil")) { _ in self?.rename(journey) },
                UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in self?.confirmDelete(journey) }
            ])
        }
    }

    fileprivate func openJourney(_ id: JourneyID) {
        guard let detail = JourneyDetailTVC(container: container, journeyId: id) else { return }
        navigationController?.pushViewController(detail, animated: true)
    }

    fileprivate func rename(_ journey: JourneySummary) {
        presentTextInput(title: "Rename journey", text: journey.name, placeholder: "Journey name") { [weak self] name in
            self?.container.updateJourney.handle(UpdateJourneyCommand(journeyId: journey.id, change: .rename(name)))
            self?.reloadJourneys()
        }
    }

    fileprivate func confirmDelete(_ journey: JourneySummary) {
        presentDestructiveConfirmation(title: "Delete \(journey.name)?",
                                       message: "The journey is removed. Your catches stay in your collection.",
                                       destructiveTitle: "Delete") { [weak self] in
            self?.container.deleteJourney.handle(DeleteJourneyCommand(journeyId: journey.id))
            self?.reloadJourneys()
        }
    }

    @objc fileprivate func addPressed() {
        let picker = PokemonPickerModalVC(container: container, configuration: .newJourney) { [weak self] name, picked in
            guard let self = self else { return }
            let id = self.container.createJourney.handle(CreateJourneyCommand(name: name, pokemonNumbers: picked.map { $0.number }))
            self.openJourney(id)
        }
        present(picker.wrapInSheet(), animated: true)
    }
}

fileprivate class JourneyCell: UITableViewCell {
    static let reuseIdentifier = "journeyCell"
    fileprivate static let maximumSprites = 6

    fileprivate let nameLabel = UILabel(style: .title3, weight: .semibold)
    fileprivate let progressLabel = UILabel(style: .footnote, color: Color.textTertiary)
    fileprivate let progressBar = UIProgressView(progressViewStyle: .default)
    fileprivate let sprites = UIStackView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = Color.surface
        let selectedBackground = UIView()
        selectedBackground.backgroundColor = Color.surfaceRaised
        selectedBackgroundView = selectedBackground
        accessoryType = .disclosureIndicator
        progressLabel.font = UIFont.make(.footnote, weight: .regular, monospacedDigits: true)
        progressBar.progressTintColor = Color.accent
        progressBar.trackTintColor = Color.surfaceRaised
        progressBar.layer.cornerRadius = CornerRadius.tiny
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

    func configure(name: String, caught: Int, members: [JourneyMember], game: Games?) {
        nameLabel.text = name
        let total = members.count
        let progress = total == 0 ? "No Pokémon yet" : (caught == total ? "Complete · all \(total) caught" : "\(caught) of \(total) caught")
        progressLabel.text = ([game?.displayName].compactMap { $0 } + [progress]).joined(separator: " · ")
        progressLabel.textColor = total > 0 && caught == total ? Color.accent : Color.textTertiary
        progressBar.progress = total == 0 ? 0 : Float(caught) / Float(total)

        for view in sprites.arrangedSubviews {
            view.removeFromSuperview()
        }
        for member in members.prefix(JourneyCell.maximumSprites) {
            let sprite = UIImageView(image: PokemonSprites.makeImage(pokemonName: member.name))
            sprite.contentMode = .scaleAspectFit
            sprite.layer.magnificationFilter = .nearest
            sprite.alpha = member.isCaught ? 1 : 0.35
            sprite.widthAnchor.constraint(equalToConstant: 44).isActive = true
            sprite.heightAnchor.constraint(equalToConstant: 44).isActive = true
            sprites.addArrangedSubview(sprite)
        }
        if (members.count > JourneyCell.maximumSprites) {
            let more = UILabel(style: .footnote, weight: .semibold, color: Color.textTertiary)
            more.text = "+\(members.count - JourneyCell.maximumSprites)"
            sprites.addArrangedSubview(more)
        }
        sprites.addArrangedSubview(UIView())
        sprites.isHidden = members.isEmpty
        accessibilityLabel = "\(name), \(progressLabel.text ?? "")"
        accessibilityTraits = .button
    }
}

fileprivate final class NextHuntCell: UITableViewCell {
    static let reuseIdentifier = "nextHuntCell"

    fileprivate let sprite = UIImageView()
    fileprivate let captionLabel = UILabel(style: .caption1, weight: .semibold, color: Color.textTertiary)
    fileprivate let nameLabel = UILabel(style: .title3, weight: .semibold)
    fileprivate let suggestionLabel = UILabel(style: .footnote, color: Color.textSecondary, lines: 0)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = Color.surface
        let selectedBackground = UIView()
        selectedBackground.backgroundColor = Color.surfaceRaised
        selectedBackgroundView = selectedBackground
        accessoryType = .disclosureIndicator
        sprite.contentMode = .scaleAspectFit
        sprite.layer.magnificationFilter = .nearest
        sprite.isAccessibilityElement = false

        let labels = UIStackView(arrangedSubviews: [captionLabel, nameLabel, suggestionLabel])
        labels.axis = .vertical
        labels.spacing = 2
        let row = UIStackView(arrangedSubviews: [sprite, labels])
        row.alignment = .center
        row.spacing = Spacing.medium
        contentView.addAutoLayoutSubviews(row)
        NSLayoutConstraint.activate([
            row.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Spacing.small),
            row.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            row.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Spacing.small),
            row.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Spacing.small),
            sprite.widthAnchor.constraint(equalToConstant: 64),
            sprite.heightAnchor.constraint(equalToConstant: 64)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(_ nextHunt: NextHunt) {
        sprite.image = PokemonSprites.makeImage(pokemonName: nextHunt.pokemonName, formId: nextHunt.formId)
        captionLabel.text = nextHunt.journeyName.uppercased()
        nameLabel.text = nextHunt.pokemonName
        suggestionLabel.text = HuntSuggestionText.describeWithArea(nextHunt.suggestion)
        isAccessibilityElement = true
        accessibilityLabel = "Hunt next for \(nextHunt.journeyName): \(nextHunt.pokemonName), \(suggestionLabel.text ?? "")"
        accessibilityTraits = .button
    }
}
