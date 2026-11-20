import UIKit

class MenuTVC: UITableViewController {
    fileprivate enum Destination {
        case pokedex(generation: Int)
        case hunts
        case collection
        case ppCounter
        case stats
        case journeys
        case bingo
    }

    fileprivate let sections: [(title: String, rows: [Int])] = [
        ("Tracking", [10, 11, 14, 13, 15, 12]),
        ("Pokédex", Array(0...9))
    ]

    let textResolver = TextResolver()
    fileprivate let container: AppContainer
    fileprivate var summary: MenuSummary?

    init(container: AppContainer) {
        self.container = container
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Menu"
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.hidesBackButton = true
        let settingsButton = UIBarButtonItem(image: UIImage(systemName: "gearshape.fill"), style: .plain, target: self, action: #selector(settingsPressed))
        settingsButton.accessibilityLabel = "Settings"
        navigationItem.rightBarButtonItem = settingsButton

        tableView.backgroundColor = Color.Grey900
        tableView.separatorColor = Color.Grey700
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.register(MenuCell.self, forCellReuseIdentifier: MenuCell.reuseIdentifier)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        summary = container.getMenuSummary.handle(GetMenuSummaryQuery())
        tableView.reloadData()
    }

    fileprivate func getMenuIndex(for indexPath: IndexPath) -> Int {
        return sections[indexPath.section].rows[indexPath.row]
    }

    fileprivate func getDestination(for index: Int) -> Destination {
        switch index {
        case 10: return .hunts
        case 11: return .collection
        case 12: return .ppCounter
        case 13: return .stats
        case 14: return .journeys
        case 15: return .bingo
        default: return .pokedex(generation: index)
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = sections[section].title
        label.font = UIFont.preferredFont(forTextStyle: .title3).withWeight(.bold)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = Color.Grey200
        label.accessibilityTraits = .header
        let container = UIView()
        container.addAutoLayoutSubviews(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: container.layoutMarginsGuide.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: container.layoutMarginsGuide.trailingAnchor),
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8)
        ])
        return container
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 52
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MenuCell.reuseIdentifier, for: indexPath) as! MenuCell
        let index = getMenuIndex(for: indexPath)
        var image = makeMenuImage(for: index)
        if (index == 10), let firstHuntPokemonName = summary?.firstHuntPokemonName {
            image = UIImage(named: firstHuntPokemonName.lowercased())
        }
        cell.configure(title: textResolver.getGenTitle(gen: index), subtitle: getSubtitle(for: index), image: image, progress: getProgress(for: index))
        return cell
    }

    fileprivate func getSubtitle(for index: Int) -> String {
        guard let summary = summary else { return "" }
        switch index {
        case 10:
            guard summary.huntCount > 0 else { return "No hunts yet" }
            let huntText = summary.huntCount == 1 ? "1 hunt" : "\(summary.huntCount) hunts"
            return "\(huntText) · \(summary.huntEncounters.grouped) encounters"
        case 11:
            return summary.caughtCount == 1 ? "1 shiny caught" : "\(summary.caughtCount.grouped) shinies caught"
        case 12:
            return "Track PP during battles"
        case 13:
            guard let average = summary.averageEncounters else { return "Averages, balls, records and more" }
            return "\(average.grouped) encounters per shiny on average"
        case 14:
            guard summary.journeyCount > 0 else { return "Badge quests, dream teams and more" }
            let journeyText = summary.journeyCount == 1 ? "1 journey" : "\(summary.journeyCount) journeys"
            return summary.completeJourneyCount == 0 ? journeyText : "\(journeyText) · \(summary.completeJourneyCount) complete"
        case 15:
            guard summary.bingoBoardCount > 0 else { return "3×3, 4×4 and 5×5 shiny bingo boards" }
            let boardText = summary.bingoBoardCount == 1 ? "1 board" : "\(summary.bingoBoardCount) boards"
            switch summary.bingoLineCount {
            case 0: return boardText
            case 1: return "\(boardText) · 1 bingo"
            default: return "\(boardText) · \(summary.bingoLineCount) bingos"
            }
        default:
            guard let progress = summary.regionProgress[index] else { return "" }
            let region = index == 8 ? "Legends: Arceus" : "Generation \(index < 8 ? index + 1 : index)"
            return "\(region) · \(progress.caught)/\(progress.total) caught"
        }
    }

    fileprivate func getProgress(for index: Int) -> Float? {
        guard let progress = summary?.regionProgress[index] else { return nil }
        return Float(progress.caught) / Float(progress.total)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let viewController: UIViewController
        switch getDestination(for: getMenuIndex(for: indexPath)) {
        case .pokedex(let generation):
            viewController = PokedexTVC(container: container, generation: generation)
        case .hunts:
            viewController = HuntsTVC(container: container)
        case .collection:
            viewController = CollectionTVC(container: container)
        case .ppCounter:
            viewController = PPCounterTVC(container: container)
        case .stats:
            viewController = StatsVC(container: container)
        case .journeys:
            viewController = JourneysTVC(container: container)
        case .bingo:
            viewController = BingoBoardsTVC(container: container)
        }
        navigationController?.pushViewController(viewController, animated: true)
    }

    fileprivate func makeMenuImage(for index: Int) -> UIImage? {
        switch index {
        case 0...7:
            return UIImage(named: "gen\(index + 1)")
        case 8:
            return UIImage(named: "hisui")
        case 9:
            return UIImage(named: "gen9")
        case 10:
            return UIImage(named: HuntMethod.Encounters.rawValue)
        case 11:
            return UIImage(named: "collection")
        case 12:
            return UIImage.makeSymbol("bolt.fill", pointSize: 20, weight: .medium)?.padded(to: CGSize(width: 56, height: 56))
        case 13:
            return UIImage.makeSymbol("chart.bar.fill", pointSize: 20, weight: .medium)?.padded(to: CGSize(width: 56, height: 56))
        case 14:
            return UIImage.makeSymbol("map.fill", pointSize: 20, weight: .medium)?.padded(to: CGSize(width: 56, height: 56))
        case 15:
            return UIImage.makeSymbol("square.grid.3x3.fill", pointSize: 20, weight: .medium)?.padded(to: CGSize(width: 56, height: 56))
        default:
            return UIImage(named: "gen1")
        }
    }

    @objc fileprivate func settingsPressed() {
        navigationController?.pushViewController(SettingsVC(container: container), animated: true)
    }
}
