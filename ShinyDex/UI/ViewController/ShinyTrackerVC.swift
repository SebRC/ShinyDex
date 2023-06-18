import UIKit
import FLAnimatedImage

class ShinyTrackerVC: UIViewController {
	@IBOutlet weak var encountersLabel: UILabel!
	@IBOutlet weak var plusButton: UIButton!
	@IBOutlet weak var minusButton: UIButton!
	@IBOutlet weak var probabilityLabel: UILabel!
	@IBOutlet weak var addToHuntButton: UIBarButtonItem!
	@IBOutlet weak var buttonStrip: ButtonStrip!
	@IBOutlet weak var gifSeparatorView: UIView!
	@IBOutlet weak var animatedImageView: FLAnimatedImageView!
    @IBOutlet weak var encountersView: UIView!
    @IBOutlet weak var probabilityView: UIView!
    
	var pokemon: Pokemon!
	var hunts = [Hunt]()
	let probabilityService = ProbabilityService()
	let oddsService = OddsService()
	var probability: Double?
	var methodDecrement = 0
	let popupHandler = PopupHandler()
	var pokemonService = PokemonService()
	var huntService = HuntService()
	var textResolver = TextResolver()
    @IBOutlet weak var encountersImageView: UIImageView!
    @IBOutlet weak var percentageImageView: UIImageView!
    
	override func viewDidLoad() {
        super.viewDidLoad()

		hunts = huntService.getAll()
		setUIColors()
		roundCorners()
		setTitle()
		setGif()
		setMethodDecrement()
		resolveEncounterDetails()
		setPokeballButtonImage()
		setMethodImage()
		setIncrementImage()
		setButtonActions()
		setOddsLabelText()
        addToHuntButton.isEnabled = addToHuntButtonIsEnabled()
        addToHuntButton.tintColor = Color.Orange500
        
        encountersImageView.image = getMethodImage()
        encountersImageView.makeCircle()
        encountersImageView.backgroundColor = Color.Grey900
        encountersImageView.layer.borderWidth = 2
        encountersImageView.layer.borderColor = Color.Orange500.cgColor
        
        percentageImageView.makeCircle()
        percentageImageView.backgroundColor = Color.Grey900
        percentageImageView.layer.borderWidth = 2
        percentageImageView.layer.borderColor = Color.Orange500.cgColor
        probabilityView.backgroundColor = Color.Grey800
        probabilityView.layer.cornerRadius = CornerRadius.standard
	}

	fileprivate func setMethodDecrement() {
		if (pokemon!.huntMethod == .SosChaining || pokemon!.huntMethod == .Lure || pokemon!.generation == 0) {
			methodDecrement = 30
		}
		else if (pokemon!.huntMethod == .ChainFishing) {
			methodDecrement = 20
		}
		else if (pokemon!.huntMethod == .Pokeradar) {
			methodDecrement = 40
		}
		else if (pokemon!.huntMethod == .DexNav) {
			methodDecrement = 999
		}
		else {
			methodDecrement = 0
		}
	}
	
	fileprivate func setPokeballButtonImage() {
		buttonStrip.pokeballButton.setImage(UIImage(named: pokemon.caughtBall), for: .normal)
	}

	fileprivate func setMethodImage() {
        let image = getMethodImage();
        encountersImageView.image = image
        buttonStrip.methodButton.setImage(image, for: .normal)
	}

	fileprivate func getMethodImage() -> UIImage {
		let huntMethod = pokemon!.huntMethod
		let canBeCombinedWithCharm = huntMethod != .Gen2Breeding && huntMethod != .Pokeradar
		if (pokemon!.isShinyCharmActive && canBeCombinedWithCharm) {
			return UIImage(named: "\(huntMethod.rawValue) + Charm")!
		}
		else {
			return UIImage(named: huntMethod.rawValue)!
		}
	}
	
	fileprivate func setUIColors() {
        view.backgroundColor = Color.Grey900
		
        encountersView.backgroundColor = Color.Grey800
        encountersLabel.textColor = Color.Grey200
        probabilityLabel.textColor = Color.Grey200
		
		gifSeparatorView.backgroundColor = Color.Grey200
        plusButton.tintColor = Color.Grey200
        minusButton.tintColor = Color.Grey200
    }
	
	fileprivate func roundCorners() {
		encountersLabel.layer.cornerRadius = CornerRadius.standard
		probabilityLabel.layer.cornerRadius = CornerRadius.standard
		gifSeparatorView.layer.cornerRadius = CornerRadius.standard
        encountersView.layer.cornerRadius = CornerRadius.standard
	}
	
	fileprivate func setTitle() {
		title = pokemon.name
	}
	
	fileprivate func setGif() {
		if let gifAsset = NSDataAsset(name: "\(pokemon.name)") {
            animatedImageView.animatedImage = FLAnimatedImage(animatedGIFData: gifAsset.data)
		}
	}
	
	fileprivate func setButtonActions() {
		buttonStrip.updateEncountersButton.addTarget(self, action: #selector(updateEncountersPressed), for: .touchUpInside)
		buttonStrip.incrementButton.addTarget(self, action: #selector(incrementButtonPressed), for: .touchUpInside)
		buttonStrip.methodButton.addTarget(self, action: #selector(infoButtonPressed), for: .touchUpInside)
		buttonStrip.pokeballButton.addTarget(self, action: #selector(changeCaughtButtonPressed), for: .touchUpInside)
		buttonStrip.locationButton.addTarget(self, action: #selector(locationButtonPressed), for: .touchUpInside)
	}
	
	fileprivate func resolveEncounterDetails() {
		setProbability()
		setProbabilityLabelText()
        encountersLabel.text = textResolver.getEncountersLabelText(pokemon: pokemon!, methodDecrement: methodDecrement)
		setOddsLabelText()
		minusButton.isEnabled = minusButtonIsEnabled()
	}
	
	fileprivate func setProbability() {
		var encounters = pokemon.encounters
		pokemon!.shinyOdds = oddsService.getShinyOdds(pokemon: pokemon)
		encounters -= methodDecrement
		probability = probabilityService.getProbability(encounters: encounters, shinyOdds: pokemon!.shinyOdds)
	}

	fileprivate func setProbabilityLabelText() {
		let probabilityLabelText = probabilityService.getProbabilityText(probability: probability!,  pokemon: pokemon!, methodDecrement: methodDecrement)
        probabilityLabel.text = probabilityLabelText
	}

	fileprivate func setOddsLabelText() {
		buttonStrip.oddsLabel.text = "1/\(pokemon!.shinyOdds)"
	}
	
	fileprivate func minusButtonIsEnabled() -> Bool {
		return pokemon.encounters != 0
	}
	
	fileprivate func addToHuntButtonIsEnabled() -> Bool {
		return !pokemon.isBeingHunted
	}
	
	@IBAction func plusPressed(_ sender: Any) {
		pokemon.encounters += pokemon!.increment
		resolveEncounterDetails()
		pokemonService.save(pokemon: pokemon)
	}
	
	@IBAction func minusPressed(_ sender: Any) {
		pokemon.encounters -= 1
		resolveEncounterDetails()
		pokemonService.save(pokemon: pokemon)
	}
	
	@IBAction func addToHuntPressed(_ sender: Any) {
		if (hunts.isEmpty) {
			huntService.createNewHuntWithPokemon(hunts: &hunts, pokemon: pokemon!)
			popupHandler.showPopup(text: "\(pokemon!.name) was added to New Hunt.")
			addToHuntButton.isEnabled = addToHuntButtonIsEnabled()
		}
		else if (hunts.count == 1) {
			huntService.addToOnlyExistingHunt(hunts: &hunts, pokemon: pokemon!)
			popupHandler.showPopup(text: "\(pokemon!.name) was added to \(hunts[0].name).")
			addToHuntButton.isEnabled = addToHuntButtonIsEnabled()
		}
		else {
			performSegue(withIdentifier: "pickHunt", sender: self)
		}
	}

	@objc fileprivate func infoButtonPressed(_ sender: Any) {
		performSegue(withIdentifier: "editInfo", sender: self)
	}

	@objc fileprivate func updateEncountersPressed(_ sender: Any) {
		performSegue(withIdentifier: "editEncounters", sender: self)
	}

	@objc fileprivate func incrementButtonPressed(_ sender: Any) {
		performSegue(withIdentifier: "editIncrement", sender: self)
	}

	@objc fileprivate func changeCaughtButtonPressed(_ sender: Any) {
		performSegue(withIdentifier: "pickPokeball", sender: self)
	}

	@objc fileprivate func locationButtonPressed(_ sender: Any) {
		performSegue(withIdentifier: "toLocation", sender: self)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		let identifier = segue.identifier
		if (identifier == "editInfo") {
			let destVC = segue.destination as! GameSettingsModalVC
			destVC.pokemon = pokemon
		}
		else if (identifier == "editEncounters") {
			let destVC = segue.destination as! SetEncountersModalVC
			destVC.pokemon = pokemon
			destVC.methodDecrement = methodDecrement
		}
		else if (identifier == "pickHunt") {
			let destVC = segue.destination as! HuntPickerModalVC
			destVC.pokemon = pokemon
		}
		else if (identifier == "toLocation") {
			let destVC = segue.destination as! LocationVC
			destVC.pokemon = pokemon
		}
		else if (identifier == "editIncrement") {
			let destVC = segue.destination as! IncrementVC
			destVC.pokemon = pokemon
		}
		else {
			let destVC = segue.destination as! PokeballModalVC
			destVC.pokemon = pokemon
		}
	}
	
	@IBAction func save(_ unwindSegue: UIStoryboardSegue) {
		if let sourceTVC = unwindSegue.source as? PokeballModalVC {
			pokemon.caughtBall = sourceTVC.pokemon.caughtBall
			buttonStrip.pokeballButton.setImage(UIImage(named: pokemon.caughtBall), for: .normal)
		}
	}
	
	@IBAction func saveEncounters(_ unwindSegue: UIStoryboardSegue) {
		let sourceVC = unwindSegue.source as! SetEncountersModalVC
		pokemon = sourceVC.pokemon
		pokemonService.save(pokemon: pokemon)
		resolveEncounterDetails()
	}

	@IBAction func finish(_ unwindSegue: UIStoryboardSegue) {
		addToHuntButton.isEnabled = addToHuntButtonIsEnabled()
		let source = unwindSegue.source as! HuntPickerModalVC
		let huntName = source.pickedHuntName
		popupHandler.showPopup(text: "\(pokemon!.name) was added to \(huntName!).")
	}

	@IBAction func dismissModal(_ unwindSegue: UIStoryboardSegue) {
		setMethodImage()
		setMethodDecrement()
		resolveEncounterDetails()
		setOddsLabelText()
	}

	@IBAction func confirmIncrement(_ unwindSegue: UIStoryboardSegue) {
		setIncrementImage()
	}

	fileprivate func setIncrementImage() {
		buttonStrip.incrementButton.setImage(UIImage(systemName: pokemon.increment > 6 ? "plus.circle.fill" : "\(pokemon!.increment).circle.fill"), for: .normal)
	}
}
