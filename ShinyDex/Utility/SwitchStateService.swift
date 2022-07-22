import Foundation
import UIKit

class SwitchStateService {
    
    func resolveHuntMethodSwitchState(pokemon: Pokemon, huntMethodSwitch: UISwitch, huntMethod: HuntMethod) {
        let switchEnabled = GamesList.games[pokemon.game]?.availableMethods.contains(huntMethod) ?? false
        if (switchEnabled) {
            enableSwitch(uiSwitch: huntMethodSwitch)
            huntMethodSwitch.isOn = pokemon.huntMethod == huntMethod
        }
        else {
            disableSwitch(uiSwitch: huntMethodSwitch)
        }
    }
	
	func resolveShinyCharmSwitchState(pokemon: Pokemon, shinyCharmSwitch: UISwitch) {
        let switchEnabled = GamesList.games[pokemon.game]?.isShinyCharmAvailable ?? false
		if (switchEnabled) {
			enableSwitch(uiSwitch: shinyCharmSwitch)
			shinyCharmSwitch.isOn = pokemon.isShinyCharmActive
		}
		else {
			disableSwitch(uiSwitch: shinyCharmSwitch)
			pokemon.isShinyCharmActive = false
		}
	}
    
	fileprivate func disableSwitch(uiSwitch: UISwitch) {
		uiSwitch.isOn = false
		uiSwitch.isEnabled = false
	}

	fileprivate func enableSwitch(uiSwitch: UISwitch) {
		uiSwitch.isEnabled = true
	}
}
