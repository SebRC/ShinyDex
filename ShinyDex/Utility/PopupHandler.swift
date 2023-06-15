import Foundation
import UIKit

class PopupHandler {
	func showPopup(text: String) {
		let popup = PopupView()
		popup.actionLabel.text = text
        let width = UIScreen.main.bounds.width / 1.5
        let x = (UIScreen.main.bounds.width / 2) - (width / 2)
		popup.frame = CGRect(x: x, y: 0, width: width, height: 50)
		centerPopupView(popupView: popup)
		popup.isHidden = false
		popup.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
		popup.alpha = 1.0
		UIView.animate(withDuration: 0.5, animations: {
            popup.frame.origin.y = 50
            
			//popup.alpha = 1.0
			//popup.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
		})
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) { self.removeAnimate(popupView: popup) }
	}

	fileprivate func removeAnimate(popupView: UIView) {
		UIView.animate(withDuration: 0.5, animations: {
			//popupView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
			//popupView.alpha = 0.0
            popupView.frame.origin.y = -100
		})
        
	}
	
	fileprivate func centerPopupView(popupView: UIView) {
		let window = UIApplication.shared.windows.filter{$0.isKeyWindow}.first
		//popupView.center = window!.center
		window!.addSubview(popupView)
	}
}
