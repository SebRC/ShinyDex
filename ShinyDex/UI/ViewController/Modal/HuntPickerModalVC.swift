import UIKit

class HuntPickerModalVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
	var hunts = [Hunt]()
	var pickedHuntName: String?
	var pokemon: Pokemon!
	var pokemonService = PokemonService()
	var huntService = HuntService()

	@IBOutlet weak var indicatorView: IndicatorView!
	@IBOutlet weak var cancelButton: UIButton!
	@IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    
	override func viewDidLoad() {
        super.viewDidLoad()
		hunts = huntService.getAll()
		tableView.delegate = self
		tableView.dataSource = self
		tableView.backgroundColor = .clear
        cancelButton.setTitleColor(Color.Danger100, for: .normal)
		cancelButton.layer.cornerRadius = CornerRadius.standard
        titleLabel.textColor = Color.Orange500
		indicatorView.pokemonImageView.image = UIImage(named: pokemon.name.lowercased())
		indicatorView.titleLabel.text = "Select a hunt to add \(pokemon.name) to it"
        tableView.separatorColor = Color.Grey900
		tableView.layer.cornerRadius = CornerRadius.standard
        view.backgroundColor = Color.Grey900
    }

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int	{
		return hunts.count
	}
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "huntPickerCell") as! HuntPickerCell
		cell.nameLabel.text = hunts[indexPath.row].name
        cell.nameLabel.textColor = Color.Grey200
		cell.iconImageView.image = UIImage(named: hunts[indexPath.row].pokemon[0].name.lowercased())
		return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let hunt = hunts[indexPath.row]
		hunt.pokemon.append(pokemon)
		hunt.indexes.append(pokemon.number)
		pokemon.isBeingHunted = true
		pokemonService.save(pokemon: pokemon)
		huntService.save(hunt: hunt)
		pickedHuntName = hunt.name
		performSegue(withIdentifier: "unwindFromHuntPicker", sender: self)
	}

	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = Color.Grey800
	}

	@IBAction func cancelPressed(_ sender: Any) {
		dismiss(animated: true)
	}
}
