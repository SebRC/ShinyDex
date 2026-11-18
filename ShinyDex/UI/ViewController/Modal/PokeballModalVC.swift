import UIKit

enum PokeballPickerResult {
	case loggedCatch
	case removedLatestCatch
	case nothingToRemove
}

class PokeballModalVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
	fileprivate let titleLabel = UILabel()
	fileprivate let indicatorView = IndicatorView(frame: .zero)
	fileprivate let pokeballTableView = UITableView(frame: .zero, style: .insetGrouped)
	fileprivate let cancelButton = UIButton(type: .system)

	fileprivate let pokemon: Pokemon
	fileprivate let onFinish: (PokeballPickerResult) -> Void
	fileprivate let catchService = CatchService()
	fileprivate var pokeballs = [Pokeball]()
	fileprivate var hasCatches = false

	init(pokemon: Pokemon, onFinish: @escaping (PokeballPickerResult) -> Void) {
		self.pokemon = pokemon
		self.onFinish = onFinish
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		pokeballs = TxtReader().readFile(textFile: "pokeballs").map { Pokeball(ballName: $0) }
		hasCatches = !catchService.getCatches(for: pokemon).isEmpty
		view.backgroundColor = Color.Grey900
		setUpTitleLabel()
		setUpIndicatorView()
		setUpTableView()
		setUpCancelButton()
		layOutSubviews()
	}

	fileprivate func setUpTitleLabel() {
		titleLabel.text = "Change caught ball"
		titleLabel.font = UIFont.boldSystemFont(ofSize: 30)
		titleLabel.textColor = Color.Orange500
	}

	fileprivate func setUpIndicatorView() {
		indicatorView.titleLabel.text = "Which ball did you catch \(pokemon.name) in?"
		indicatorView.pokemonImageView.image = UIImage(named: pokemon.name.lowercased())
	}

	fileprivate func setUpTableView() {
		pokeballTableView.register(PokeballCell.self, forCellReuseIdentifier: PokeballCell.reuseIdentifier)
		pokeballTableView.dataSource = self
		pokeballTableView.delegate = self
		pokeballTableView.backgroundColor = .clear
		pokeballTableView.separatorColor = Color.Grey900
		pokeballTableView.layer.cornerRadius = CornerRadius.standard
	}

	fileprivate func setUpCancelButton() {
		cancelButton.setTitle("Cancel", for: .normal)
		cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 25)
		cancelButton.backgroundColor = Color.Danger500
		cancelButton.setTitleColor(Color.Danger100, for: .normal)
		cancelButton.layer.cornerRadius = CornerRadius.standard
		cancelButton.addTarget(self, action: #selector(cancelPressed), for: .touchUpInside)
	}

	fileprivate func layOutSubviews() {
		for subview in [titleLabel, indicatorView, pokeballTableView, cancelButton] {
			subview.translatesAutoresizingMaskIntoConstraints = false
			view.addSubview(subview)
		}
		let safeArea = view.safeAreaLayoutGuide
		NSLayoutConstraint.activate([
			titleLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 20),
			titleLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
			titleLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),
			titleLabel.heightAnchor.constraint(equalToConstant: 48),

			indicatorView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
			indicatorView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
			indicatorView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),
			indicatorView.heightAnchor.constraint(equalToConstant: 100),

			pokeballTableView.topAnchor.constraint(equalTo: indicatorView.bottomAnchor, constant: 18),
			pokeballTableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
			pokeballTableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),

			cancelButton.topAnchor.constraint(equalTo: pokeballTableView.bottomAnchor, constant: 18),
			cancelButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
			cancelButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),
			cancelButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -26),
			cancelButton.heightAnchor.constraint(equalToConstant: 46)
		])
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 100.0
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return pokeballs.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: PokeballCell.reuseIdentifier, for: indexPath) as! PokeballCell
		let pokeball = pokeballs[indexPath.row]
		let ballName = pokeball.name.lowercased()
		let isNoneRow = ballName == CatchRules.noBall
		cell.configure(pokeball: pokeball,
					   title: isNoneRow && hasCatches ? "Remove latest catch" : pokeball.name,
					   isCurrentBall: !isNoneRow && ballName == pokemon.caughtBall)
		return cell
	}

	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		cell.backgroundColor = Color.Grey800
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		onFinish(pickBall(named: pokeballs[indexPath.row].name.lowercased()))
		dismiss(animated: true)
	}

	fileprivate func pickBall(named caughtBall: String) -> PokeballPickerResult {
		if (caughtBall != CatchRules.noBall) {
			catchService.logCatch(pokemon: pokemon, caughtBall: caughtBall)
			return .loggedCatch
		}
		return catchService.removeLatestCatch(pokemon: pokemon) ? .removedLatestCatch : .nothingToRemove
	}

	@objc fileprivate func cancelPressed() {
		dismiss(animated: true)
	}
}
