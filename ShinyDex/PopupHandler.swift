////
////  PopupHandler.swift
////  ShinyDexPrototype
////
////  Created by Sebastian Christiansen on 09/11/2019.
////  Copyright © 2019 Sebastian Christiansen. All rights reserved.
////
//
//import Foundation
//import UIKit
//
//class PopupHandler
//{
//	func showPopup(popupView: UIView)
//	{
//		popupView.isHidden = false
//		popupView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
//		popupView.alpha = 0.0
//		UIView.animate(withDuration: 0.25, animations: {
//			popupView.alpha = 1.0
//			
//			popupView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
//		})
//		
//		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2)
//		{
//			self.removeAnimate(popupView: popupView)
//		}
//	}
//
//	func removeAnimate(popupView: UIView)
//	{
//		UIView.animate(withDuration: 0.25, animations: {
//			popupView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
//			popupView.alpha = 0.0
//		})
//	}
//	
//	func centerPopupView(popupView: PopupView)
//	{
//		let window = UIApplication.shared.windows.filter{$0.isKeyWindow}.first
//		
//		popupView.center = window!.center
//		
//		window!.addSubview(popupView)
//	}
//	
//}
