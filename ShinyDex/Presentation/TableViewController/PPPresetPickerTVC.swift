import UIKit

class PPPresetPickerTVC: UITableViewController, UISearchResultsUpdating {
    fileprivate struct GameSection {
        let game: String
        let presets: [PPPresetSummary]
    }

    fileprivate static let spriteSize = CGSize(width: 56, height: 48)

    fileprivate let presets: [PPPresetSummary]
    fileprivate var sections = [GameSection]()
    fileprivate let searchController = UISearchController(searchResultsController: nil)
    var onPick: ((PPPresetSummary) -> Void)?

    init(presets: [PPPresetSummary]) {
        self.presets = presets
        super.init(style: .insetGrouped)
        title = "Presets"
        sections = PPPresetPickerTVC.groupByGame(presets)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        tableView.backgroundColor = Color.background
        tableView.separatorColor = Color.separator
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Pokémon or games"
        searchController.searchBar.tintColor = Color.accent
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }

    func updateSearchResults(for searchController: UISearchController) {
        let query = searchController.searchBar.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let matching = query.isEmpty ? presets : presets.filter {
            $0.pokemonName.localizedCaseInsensitiveContains(query) || $0.game.localizedCaseInsensitiveContains(query)
        }
        sections = PPPresetPickerTVC.groupByGame(matching)
        tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].presets.count
    }


    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return SectionHeaderView.make(for: tableView, title: makeHeaderTitle(for: section))
    }

    fileprivate func makeHeaderTitle(for section: Int) -> String? {
        return sections[section].game
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let preset = sections[indexPath.section].presets[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.backgroundColor = Color.surface
        let selectedBackground = UIView()
        selectedBackground.backgroundColor = Color.surfaceRaised
        cell.selectedBackgroundView = selectedBackground
        cell.textLabel?.text = "\(preset.pokemonName) · Lv. \(preset.level)"
        cell.textLabel?.font = UIFont.make(.body, weight: .semibold)
        cell.textLabel?.textColor = Color.textPrimary
        cell.detailTextLabel?.text = PPPresetPickerTVC.makeDetail(for: preset)
        cell.detailTextLabel?.font = UIFont.make(.subheadline)
        cell.detailTextLabel?.textColor = Color.textTertiary
        cell.detailTextLabel?.numberOfLines = 0
        cell.imageView?.image = PokemonSprites.makeImage(pokemonName: preset.pokemonName)?.resized(to: PPPresetPickerTVC.spriteSize)
        cell.imageView?.layer.magnificationFilter = .nearest
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        Haptics.tap()
        onPick?(sections[indexPath.section].presets[indexPath.row])
    }

    fileprivate static func groupByGame(_ presets: [PPPresetSummary]) -> [GameSection] {
        var sections = [GameSection]()
        for preset in presets {
            if let last = sections.last, last.game == preset.game {
                sections[sections.count - 1] = GameSection(game: last.game, presets: last.presets + [preset])
            } else {
                sections.append(GameSection(game: preset.game, presets: [preset]))
            }
        }
        return sections
    }

    fileprivate static func makeDetail(for preset: PPPresetSummary) -> String {
        let moves = preset.moveNames.joined(separator: " · ")
        let notes = [preset.onlyIn.map { "\($0) only" }, preset.isRoaming ? "Roaming" : nil].compactMap { $0 }
        return notes.isEmpty ? moves : "\(moves)\n\(notes.joined(separator: " · "))"
    }
}
