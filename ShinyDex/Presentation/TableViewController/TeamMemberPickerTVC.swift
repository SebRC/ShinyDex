import UIKit

final class TeamMemberPickerTVC: UITableViewController, UISearchBarDelegate {
    fileprivate static let cellIdentifier = "teamCandidateCell"
    fileprivate static let spriteSide: CGFloat = 48

    fileprivate let container: AppContainer
    fileprivate let teamId: TeamID
    fileprivate let onPick: (TeamMember) -> Void
    fileprivate let searchBar = UISearchBar()
    fileprivate var allCandidates = [TeamMember]()
    fileprivate var candidates = [TeamMember]()
    fileprivate var hasAppeared = false

    init(container: AppContainer, teamId: TeamID, onPick: @escaping (TeamMember) -> Void) {
        self.container = container
        self.teamId = teamId
        self.onPick = onPick
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add Battler"
        navigationItem.largeTitleDisplayMode = .never
        tableView.backgroundColor = Color.background
        tableView.separatorColor = Color.separator
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: TeamMemberPickerTVC.cellIdentifier)
        tableView.keyboardDismissMode = .onDrag
        searchBar.delegate = self
        searchBar.placeholder = "Search by name or type"
        searchBar.searchBarStyle = .minimal
        searchBar.returnKeyType = .done
        searchBar.sizeToFit()
        tableView.tableHeaderView = searchBar
        allCandidates = container.getTeamCandidates.handle(GetTeamCandidatesQuery(teamId: teamId))
        candidates = allCandidates
        updateEmptyState()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !hasAppeared, !allCandidates.isEmpty else { return }
        hasAppeared = true
        searchBar.becomeFirstResponder()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let query = searchText.trimmingCharacters(in: .whitespaces).lowercased()
        candidates = query.isEmpty ? allCandidates : allCandidates.filter { TeamMemberPickerTVC.matches($0, query: query) }
        tableView.reloadData()
        updateEmptyState()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    fileprivate static func matches(_ member: TeamMember, query: String) -> Bool {
        let names = [member.title, member.battler.pokemonName] + member.types.map { $0.name }
        return names.contains { $0.lowercased().contains(query) }
    }

    fileprivate func updateEmptyState() {
        if (allCandidates.isEmpty) {
            tableView.backgroundView = EmptyStateView(symbolName: "person.crop.circle.badge.questionmark", title: "No battlers to add", message: "Log IVs on a catch to make it a battler.")
        }
        else {
            tableView.backgroundView = candidates.isEmpty ? EmptyStateView(symbolName: "magnifyingglass", title: "No matches", message: "Try another name or type.") : nil
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return candidates.count
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return candidates.isEmpty ? nil : "Sorted by readiness."
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TeamMemberPickerTVC.cellIdentifier, for: indexPath)
        cell.contentConfiguration = candidates[indexPath.row].makeContentConfiguration(spriteSide: TeamMemberPickerTVC.spriteSide)
        cell.backgroundColor = Color.surface
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        onPick(candidates[indexPath.row])
        searchBar.resignFirstResponder()
        navigationController?.popViewController(animated: true)
    }
}
