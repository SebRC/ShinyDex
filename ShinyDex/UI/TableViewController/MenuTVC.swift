import UIKit

class MenuTVC: UITableViewController {
	var genIndex = 0
	var hunts = [Hunt]()
	let textResolver = TextResolver()
	var pokemonService = PokemonService()
	var colorService = ColorService()
	var huntService = HuntService()

	@IBOutlet weak var settingsButton: UIBarButtonItem!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		hideBackButton()

		tableView.separatorColor = colorService.getSecondaryColor()

		hunts = huntService.getAll()
		
		showNavigationBar()

		setNavigationControllerColor()
		
		setNavigationBarFont()
		
		setSettingsIconColor()
        
        navigationController?.navigationBar.prefersLargeTitles = true
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		hunts = huntService.getAll()
		
		setTableViewBackgroundColor()

		tableView.separatorColor = colorService.getSecondaryColor()
		
		tableView.reloadData()
		
		setUpBackButton()
		
		setNavigationBarFont()
		
		setSettingsIconColor()
	}
	
	fileprivate func hideBackButton() {
		navigationItem.hidesBackButton = true
	}
	
	fileprivate func showNavigationBar() {
		navigationController?.isNavigationBarHidden = false
	}
	
	fileprivate func setNavigationControllerColor() {
		navigationController?.navigationBar.barTintColor = colorService.getSecondaryColor()
	}
	
	fileprivate func setNavigationBarFont() {
		let navigationBarTitleTextAttributes = [
			NSAttributedString.Key.foregroundColor: colorService.getTertiaryColor(),
		]
		navigationController?.navigationBar.titleTextAttributes = navigationBarTitleTextAttributes
	}
	
	fileprivate func setSettingsIconColor() {
		settingsButton.tintColor = colorService.getTertiaryColor()
	}
	
	fileprivate func setTableViewBackgroundColor() {
		tableView.backgroundColor = colorService.getSecondaryColor()
	}

	fileprivate func setUpBackButton() {
		let backButton = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: self, action: nil)
		
		navigationItem.backBarButtonItem = backButton
		
		navigationController?.navigationBar.tintColor = colorService.getTertiaryColor()
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 11
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 160.0;
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		genIndex = indexPath.row
		if (genIndex == 8) {
			performSegue(withIdentifier: "toHunts", sender: self)
		} else if (genIndex == 10) {
			performSegue(withIdentifier: "toPPCounter", sender: self)
		}
		else {
			performSegue(withIdentifier: "toPokedex", sender: self)
		}
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell 	{
		let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell", for: indexPath) as! MenuCell
		
		let showCurrentHuntImage = indexPath.row == 8 && !hunts.isEmpty
		
		cell.generationLabel.textColor = colorService.getTertiaryColor()
		
		if (showCurrentHuntImage) {
			cell.generationImage.image = UIImage(named: hunts[0].pokemon[0].name.lowercased())
		}
		else {
			cell.generationImage.image = resolveGenImage(gen: indexPath.row)
		}
		
		cell.generationLabel.text = textResolver.getGenTitle(gen: indexPath.row)
		
		return cell
	}
	
	fileprivate func resolveGenImage(gen : Int) -> UIImage {
		switch gen {
		case 0:
			return UIImage(named: "gen1")!
		case 1:
			return UIImage(named: "gen2")!
		case 2:
			return UIImage(named: "gen3")!
		case 3:
			return UIImage(named: "gen4")!
		case 4:
			return UIImage(named: "gen5")!
		case 5:
			return UIImage(named: "gen6")!
		case 6:
			return UIImage(named: "gen7")!
		case 7:
			return UIImage(named: "gen8")!
		case 8:
			return UIImage(named: "\(HuntMethod.Encounters.rawValue) + Charm")!
		case 9:
			return UIImage(named: "collection")!
		case 10:
			return UIImage(named: "journal")!
		default:
			return UIImage(named: "gen1")!
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if (segue.identifier == "toSettings") {
			let destVC = segue.destination as? SettingsVC
			destVC?.pokemon = Pokemon()
		}
		else {
			let destVC = segue.destination as? PokedexTVC
			destVC?.generation = genIndex
		}
	}
	
	@IBAction func settingsPressed(_ sender: Any) {
		performSegue(withIdentifier: "toSettings", sender: self)
	}
	
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		cell.backgroundColor = colorService.getPrimaryColor()
	}
}
