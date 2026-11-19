import Foundation
import UIKit

class SwitchStateService {
    
    func resolveHuntMethodSwitchState(settings: HuntSettings, huntMethodSwitch: UISwitch, huntMethod: HuntMethod) {
        let switchEnabled = GamesList.games[settings.game]?.availableMethods.contains(huntMethod) ?? false
        if (switchEnabled) {
            enableSwitch(uiSwitch: huntMethodSwitch)
            huntMethodSwitch.isOn = settings.huntMethod == huntMethod
        }
        else {
            disableSwitch(uiSwitch: huntMethodSwitch)
        }
    }
	
	func resolveShinyCharmSwitchState(settings: HuntSettings, shinyCharmSwitch: UISwitch) {
        let switchEnabled = GamesList.games[settings.game]?.isShinyCharmAvailable ?? false
		if (switchEnabled) {
			enableSwitch(uiSwitch: shinyCharmSwitch)
			shinyCharmSwitch.isOn = settings.isShinyCharmActive
		}
		else {
			disableSwitch(uiSwitch: shinyCharmSwitch)
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
