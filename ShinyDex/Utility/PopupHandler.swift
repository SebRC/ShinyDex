//
//  PopupHandler.swift
//  ShinyDexPrototype
//
//  Created by Sebastian Christiansen on 09/11/2019.
//  Copyright © 2019 Sebastian Christiansen. All rights reserved.
//

import Foundation
import UIKit

class PopupHandler {
	func showPopup(text: String) {
		let popup = PopupView()
		popup.actionLabel.text = text
		popup.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width / 1.25, height: 50)
		centerPopupView(popupView: popup)
		popup.isHidden = false
		popup.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
		popup.alpha = 0.0
		UIView.animate(withDuration: 0.25, animations: {
			popup.alpha = 1.0
			
			popup.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
		})
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) { self.removeAnimate(popupView: popup) }
	}

	fileprivate func removeAnimate(popupView: UIView) {
		UIView.animate(withDuration: 0.25, animations: {
			popupView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
			popupView.alpha = 0.0
		})
	}
	
	fileprivate func centerPopupView(popupView: UIView) {
		let window = UIApplication.shared.windows.filter{$0.isKeyWindow}.first
		popupView.center = window!.center
		window!.addSubview(popupView)
	}
}
