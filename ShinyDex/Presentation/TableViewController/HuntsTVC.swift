import UIKit

class HuntsTVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    fileprivate let container: AppContainer
    var popupHandler = PopupHandler()
    fileprivate var hunts = [HuntSummary]()

    fileprivate var totalEncounters: Int {
        return hunts.reduce(0) { $0 + $1.totalEncounters }
    }

    fileprivate let createHuntButton = HuntsTVC.makeCreateHuntButton()
    fileprivate let tableView = UITableView(frame: .zero, style: .insetGrouped)
    fileprivate let moreButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"), menu: nil)

    init(container: AppContainer) {
        self.container = container
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func reloadHunts() {
        hunts = container.getHunts.handle(GetHuntsQuery())
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        reloadHunts()
        layOutViews()
        tableView.register(CurrentHuntCell.self, forCellReuseIdentifier: CurrentHuntCell.reuseIdentifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(HuntHeaderView.self, forHeaderFooterViewReuseIdentifier: HuntHeaderView.reuseIdentifier)
        tableView.estimatedSectionHeaderHeight = 64
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        view.backgroundColor = Color.Grey900
        navigationItem.title = "Hunts"
        createHuntButton.accessibilityLabel = "Create hunt"
        moreButton.accessibilityLabel = "More"
        updateMoreMenu()
    }

    fileprivate static func makeCreateHuntButton() -> UIButton {
        var configuration = UIButton.Configuration.filled()
        configuration.baseBackgroundColor = Color.Orange500
        configuration.baseForegroundColor = Color.Grey900
        configuration.cornerStyle = .large
        configuration.image = UIImage.makeSymbol("plus.circle.fill", pointSize: 20, weight: .semibold)
        configuration.imagePadding = 8
        var title = AttributedString("Create Hunt")
        title.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        configuration.attributedTitle = title
        let button = UIButton(configuration: configuration)
        button.layer.shadowColor = Color.Orange500.cgColor
        button.layer.shadowOpacity = 0.25
        button.layer.shadowRadius = 10
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        return button
    }

    fileprivate func layOutViews() {
        navigationItem.rightBarButtonItem = moreButton

        createHuntButton.addTarget(self, action: #selector(createHuntButtonPressed), for: .touchUpInside)

        view.addAutoLayoutSubviews(tableView, createHuntButton)
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            createHuntButton.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 16),
            createHuntButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            createHuntButton.heightAnchor.constraint(equalToConstant: 52),
            createHuntButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),

            tableView.topAnchor.constraint(equalTo: createHuntButton.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        reloadHunts()
        setColors()
        setEncounters()
        reloadData()
    }

    fileprivate func updateMoreMenu() {
        let rearrange = UIAction(title: "Rearrange hunts", image: UIImage(systemName: "line.3.horizontal"),
                                 attributes: hunts.count > 1 ? [] : .disabled) { [weak self] _ in
            self?.rearrangePressed()
        }
        let clear = UIAction(title: "Clear all hunts", image: UIImage(systemName: "trash"),
                             attributes: hunts.isEmpty ? [.destructive, .disabled] : .destructive) { [weak self] _ in
            self?.clearAllHuntsPressed()
        }
        moreButton.menu = UIMenu(children: [rearrange, UIMenu(options: .displayInline, children: [clear])])
        moreButton.isEnabled = !hunts.isEmpty
    }
    
    fileprivate func setColors() {
        tableView.backgroundColor = Color.Grey900
        tableView.separatorColor = Color.Grey700
    }
    
    fileprivate func setEncounters() {
        updateSummary()
    }

    fileprivate func updateSummary() {
        guard !hunts.isEmpty else {
            tableView.tableHeaderView = nil
            return
        }
        let label = (tableView.tableHeaderView as? UILabel) ?? UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = Color.Grey400
        label.text = totalEncounters == 1 ? "1 encounter across all hunts" : "\(totalEncounters.grouped) encounters across all hunts"
        label.accessibilityTraits = .header
        let height = label.font.lineHeight + 8
        label.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: height)
        label.textAlignment = .center
        tableView.tableHeaderView = label
    }

    fileprivate func updateEmptyState() {
        guard hunts.isEmpty else {
            tableView.backgroundView = nil
            return
        }
        tableView.backgroundView = EmptyStateView(symbolName: "sparkles",
                                                  title: "No hunts yet",
                                                  message: "Tap Create Hunt, or add a Pokémon from the Pokédex, to start counting encounters.")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int	{
        return hunts.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (hunts[section].isCollapsed) {
            return 0
        }
        return hunts[section].members.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CurrentHuntCell.reuseIdentifier, for: indexPath) as! CurrentHuntCell
        cell.onIncrement = { [weak self, weak cell] in
            guard let self = self, let cell = cell, let indexPath = self.tableView.indexPath(for: cell) else { return }
            self.incrementEncounters(at: indexPath)
        }
        cell.onDecrement = { [weak self, weak cell] in
            guard let self = self, let cell = cell, let indexPath = self.tableView.indexPath(for: cell) else { return }
            self.decrementEncounters(at: indexPath)
        }
        
        cell.configure(pokemon: hunts[indexPath.section].members[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: HuntHeaderView.reuseIdentifier) as! HuntHeaderView
        let hunt = hunts[section]
        header.configure(hunt: hunt)
        header.onToggleCollapse = { [weak self] in
            guard let self = self, let index = self.hunts.firstIndex(where: { $0.id == hunt.id }) else { return }
            self.collapseSection(index)
        }
        header.onIncrementAll = { [weak self] in
            guard let self = self, let index = self.hunts.firstIndex(where: { $0.id == hunt.id }) else { return }
            self.incrementAllInHunt(index)
        }
        header.onRename = { [weak self] in
            self?.presentRename(hunt: hunt)
        }
        return header
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 8
    }

    fileprivate func collapseSection(_ section: Int) {
        let hunt = hunts[section]
        let indexPaths = hunt.members.indices.map { IndexPath(row: $0, section: section) }
        container.updateHunt.handle(UpdateHuntCommand(huntId: hunt.id, change: .setCollapsed(!hunt.isCollapsed)))
        reloadHunts()
        if (hunt.isCollapsed) {
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
        else {
            tableView.deleteRows(at: indexPaths, with: .automatic)
        }
        reloadData(duration: 0.2)
    }

    fileprivate func presentRename(hunt: HuntSummary) {
        presentTextInput(title: "Rename hunt", text: hunt.name, placeholder: "Hunt name") { [weak self] name in
            guard let self = self else { return }
            self.container.updateHunt.handle(UpdateHuntCommand(huntId: hunt.id, change: .rename(name)))
            self.reloadHunts()
            self.tableView.reloadData()
        }
    }

    fileprivate func incrementAllInHunt(_ section: Int) {
        let milestones = container.incrementAllInHunt.handle(IncrementAllInHuntCommand(huntId: hunts[section].id))
        reloadHunts()
        updateSummary()
        reloadData(duration: 0.2)
        MilestoneCelebration.announce(milestones)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
            for milestone in milestones {
                self?.animate(milestone, inSection: section)
            }
        }
    }

    fileprivate func decrementEncounters(at indexPath: IndexPath) {
        guard hunts[indexPath.section].members[indexPath.row].encounters > 0 else { return }
        Haptics.tap()
        changeEncounters(at: indexPath, .decrement)
    }

    fileprivate func incrementEncounters(at indexPath: IndexPath) {
        Haptics.tap()
        changeEncounters(at: indexPath, .increment)
    }

    fileprivate func changeEncounters(at indexPath: IndexPath, _ change: ChangeEncountersCommand.Change) {
        let number = hunts[indexPath.section].members[indexPath.row].number
        let milestone = container.changeEncounters.handle(ChangeEncountersCommand(number: number, change: change))
        reloadHunts()
        updateSummary()
        reloadSectionKeepingHeader(indexPath)
        if let milestone = milestone {
            MilestoneCelebration.announce([milestone])
            animate(milestone, inSection: indexPath.section)
        }
    }

    fileprivate func animate(_ milestone: ReachedMilestone, inSection section: Int) {
        guard hunts.indices.contains(section),
              let row = hunts[section].members.firstIndex(where: { $0.number == milestone.number }),
              let cell = tableView.cellForRow(at: IndexPath(row: row, section: section)) as? CurrentHuntCell else { return }
        MilestoneCelebration.animate(milestone, on: cell.encountersLabel, in: view)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] (_, _, completionHandler) in
            guard let self = self else { return }
            let hunt = self.hunts[indexPath.section]
            self.container.removePokemonFromHunt.handle(RemovePokemonFromHuntCommand(huntId: hunt.id, number: hunt.members[indexPath.row].number))
            self.reloadHunts()
            if (self.hunts.contains { $0.id == hunt.id }) {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            else {
                tableView.deleteSections(IndexSet(integer: indexPath.section), with: .fade)
            }
            self.updateSummary()
            self.updateMoreMenu()
            self.reloadData()
            completionHandler(true)
        }
        deleteAction.title = "Remove"
        deleteAction.image = UIImage(systemName: "minus.circle.fill")
        deleteAction.backgroundColor = .systemRed
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let tracker = ShinyTrackerVC(container: container, number: hunts[indexPath.section].members[indexPath.row].number) else { return }
        navigationController?.pushViewController(tracker, animated: true)
    }
    
    fileprivate func clearAllHuntsPressed() {
        presentDestructiveConfirmation(title: "Clear all hunts?",
                                       message: "Every hunt will be removed. Encounter counts are kept on each Pokémon.",
                                       destructiveTitle: "Clear Hunts") { [weak self] in
            self?.container.clearHunts.handle(ClearHuntsCommand())
            self?.clearAllHunts()
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = Color.Grey800
    }
    
    fileprivate func clearAllHunts() {
        hunts.removeAll()
        reloadData()
        setEncounters()
        updateMoreMenu()
    }

    fileprivate func huntsChanged() {
        reloadHunts()
        reloadData()
        setEncounters()
        updateMoreMenu()
    }

    @objc fileprivate func createHuntButtonPressed() {
        let createHunt = PokemonPickerModalVC(container: container, configuration: .hunt) { [weak self] name, picked in
            self?.container.createHunt.handle(CreateHuntCommand(name: name, pokemonNumbers: picked.map { $0.number }))
            self?.huntsChanged()
        }
        present(createHunt.wrapInSheet(), animated: true)
    }

    fileprivate func rearrangePressed() {
        let rearrange = RearrangeHuntsTVC(container: container) { [weak self] in
            self?.huntsChanged()
        }
        present(rearrange.wrapInSheet(), animated: true)
    }

    fileprivate func reloadData(duration: Double = 0.5) {
        updateEmptyState()
        UIView.transition(with: tableView, duration: duration, options: .transitionCrossDissolve, animations: {
            self.tableView.reloadData()
        }, completion: nil)
    }

    fileprivate func reloadSectionKeepingHeader(_ indexPath: IndexPath) {
        UIView.performWithoutAnimation {
            tableView.reloadRows(at: [indexPath], with: .none)
        }
        if let header = tableView.headerView(forSection: indexPath.section) as? HuntHeaderView {
            header.configure(hunt: hunts[indexPath.section])
        }
    }
}
