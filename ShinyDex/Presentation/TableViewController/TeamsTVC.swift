import UIKit

final class TeamsTVC: UITableViewController {
    fileprivate static let cellIdentifier = "teamCell"

    fileprivate let container: AppContainer
    fileprivate var teams = [TeamOverview]()

    init(container: AppContainer) {
        self.container = container
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Teams"
        navigationItem.largeTitleDisplayMode = .never
        tableView.backgroundColor = Color.background
        tableView.separatorColor = Color.separator
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: TeamsTVC.cellIdentifier)
        let addButton = UIBarButtonItem(image: UIImage(systemName: "plus.circle"), style: .plain, target: self, action: #selector(addTeamPressed))
        addButton.accessibilityLabel = "New team"
        navigationItem.rightBarButtonItem = addButton
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadTeams()
    }

    fileprivate func reloadTeams() {
        teams = container.getTeams.handle(GetTeamsQuery())
        tableView.reloadData()
        tableView.backgroundView = teams.isEmpty
            ? EmptyStateView(symbolName: "person.3", title: "No teams", message: "Build a team of up to six battlers to see its type coverage, shared weaknesses and readiness.")
            : nil
    }

    // MARK: Actions

    @objc fileprivate func addTeamPressed() {
        presentTextInput(title: "New Team", text: "Team \(teams.count + 1)", placeholder: "Name", saveTitle: "Create") { [weak self] name in
            guard let self = self else { return }
            let teamId = self.container.createTeam.handle(CreateTeamCommand(name: name))
            Haptics.playSuccess()
            self.navigationController?.pushViewController(TeamTVC(container: self.container, teamId: teamId), animated: true)
        }
    }

    // MARK: Table view

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teams.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TeamsTVC.cellIdentifier, for: indexPath)
        let team = teams[indexPath.row]
        var content = UIListContentConfiguration.subtitleCell()
        content.text = team.name
        content.textProperties.font = UIFont.make(.body, weight: .semibold)
        content.textProperties.color = Color.textPrimary
        let readiness = team.averageReadiness.map { "Readiness \($0)" }
        let names = team.members.isEmpty ? "No battlers yet" : team.members.map { $0.title }.joined(separator: ", ")
        content.secondaryText = ["\(team.members.count)/\(Team.maximumSize)", readiness, names].compactMap { $0 }.joined(separator: " · ")
        content.secondaryTextProperties.font = UIFont.make(.footnote)
        content.secondaryTextProperties.color = Color.textTertiary
        cell.contentConfiguration = content
        cell.backgroundColor = Color.surface
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.pushViewController(TeamTVC(container: container, teamId: teams[indexPath.row].id), animated: true)
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let team = teams[indexPath.row]
        let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            self?.presentDestructiveConfirmation(title: "Delete \(team.name)?", message: "The battlers stay in your collection.", destructiveTitle: "Delete") {
                self?.container.deleteTeam.handle(DeleteTeamCommand(teamId: team.id))
                self?.reloadTeams()
            }
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }
}
