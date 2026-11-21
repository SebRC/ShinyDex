import UIKit

class TechniquesInfoTVC: UITableViewController {
    struct Explanation {
        let title: String
        let body: String
    }

    fileprivate let explanations: [Explanation]

    init(explanations: [Explanation]) {
        self.explanations = explanations
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Lead techniques"
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closePressed))
        tableView.backgroundColor = Color.background
        tableView.separatorColor = Color.separator
        tableView.rowHeight = UITableView.automaticDimension
        tableView.allowsSelection = false
    }

    @objc fileprivate func closePressed() {
        dismissSheet()
    }

    // MARK: Table

    override func numberOfSections(in tableView: UITableView) -> Int {
        return explanations.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return SectionHeaderView.make(for: tableView, title: explanations[section].title)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.backgroundColor = Color.surface
        cell.textLabel?.text = explanations[indexPath.section].body
        cell.textLabel?.font = UIFont.make(.body)
        cell.textLabel?.textColor = Color.textSecondary
        cell.textLabel?.numberOfLines = 0
        return cell
    }
}
