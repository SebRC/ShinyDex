import UIKit

class ConfirmationModalVC: UIViewController {
	var huntService = HuntService()

	@IBOutlet weak var confirmationPopup: ConfirmationPopup!
	
	override func viewDidLoad() {
        super.viewDidLoad()
        confirmationPopup.cancelButton.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        confirmationPopup.confirmButton.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
        view.addBlur()
    }
	
	@objc func cancelAction(sender: UIButton!) {
		dismiss(animated: true)
	}
	
	@objc func confirmAction(sender: UIButton!) {
		huntService.clear()
		performSegue(withIdentifier: "unwindFromConfirmation", sender: self)
	}
}
