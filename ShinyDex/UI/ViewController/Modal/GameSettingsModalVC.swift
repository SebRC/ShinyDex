import UIKit

/// Game settings for one Pokémon, presented from its tracker. Present it with `inSheet()`.
/// Changes are saved as they're made; `onDismiss` lets the tracker refresh however the sheet is closed.
class GameSettingsModalVC: GameSettingsHostVC, UIAdaptivePresentationControllerDelegate {
	fileprivate let onDismiss: () -> Void

	init(pokemon: Pokemon, onDismiss: @escaping () -> Void) {
		self.onDismiss = onDismiss
		super.init(pokemon: pokemon)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		title = "Game settings"
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePressed))
		navigationController?.presentationController?.delegate = self
	}

	@objc fileprivate func donePressed() {
		dismissSheet { [onDismiss] in
			onDismiss()
		}
	}

	func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
		onDismiss()
	}
}
