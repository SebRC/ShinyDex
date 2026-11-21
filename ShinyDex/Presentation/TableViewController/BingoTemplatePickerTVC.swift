import UIKit

class BingoTemplatePickerTVC: UITableViewController {
    fileprivate static let spriteSize = CGSize(width: 68, height: 56)

    fileprivate let templates: [BingoTemplateSummary]
    fileprivate let size: BingoBoardSize
    fileprivate let onPick: (BingoTemplateSummary) -> Void

    init(templates: [BingoTemplateSummary], size: BingoBoardSize, onPick: @escaping (BingoTemplateSummary) -> Void) {
        self.templates = templates
        self.size = size
        self.onPick = onPick
        super.init(style: .insetGrouped)
        title = "Templates"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        tableView.backgroundColor = Color.background
        tableView.separatorColor = Color.separator
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return templates.count
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "Squares are filled at random from the template. Templates smaller than the board leave the rest empty."
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let template = templates[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.backgroundColor = Color.surface
        let selectedBackground = UIView()
        selectedBackground.backgroundColor = Color.surfaceRaised
        cell.selectedBackgroundView = selectedBackground
        cell.textLabel?.text = template.name
        cell.textLabel?.textColor = Color.textPrimary
        cell.detailTextLabel?.text = BingoTemplatePickerTVC.makeSubtitle(for: template, size: size)
        cell.detailTextLabel?.textColor = Color.textTertiary
        cell.imageView?.image = template.coverPokemonName
            .flatMap { PokemonSprites.makeImage(pokemonName: $0, formId: template.coverFormId) }?
            .resized(to: BingoTemplatePickerTVC.spriteSize)
        cell.imageView?.layer.magnificationFilter = .nearest
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        Haptics.tap()
        onPick(templates[indexPath.row])
    }

    fileprivate static func makeSubtitle(for template: BingoTemplateSummary, size: BingoBoardSize) -> String {
        let count = "\(template.pokemonCount) Pokémon"
        return template.pokemonCount < size.cellCount ? "\(count) · fills \(template.pokemonCount) of \(size.cellCount) squares" : count
    }
}
