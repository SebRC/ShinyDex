//
//  PopupHandlerTests.swift
//  ShinyDexTests
//
//  Created by Sebastian Christiansen on 28/05/2021.
//  Copyright © 2021 Sebastian Christiansen. All rights reserved.
//

import XCTest
@testable import ShinyDex

class PopupHandlerTests: XCTestCase {
	var popupHandler: PopupHandler!

    override func setUpWithError() throws {
		try super.setUpWithError()
		popupHandler = PopupHandler()
    }

    override func tearDownWithError() throws {
        popupHandler = nil
		try super.tearDownWithError()
    }

    func test_showPopup_doesNotCrash() throws {
		// Act + Assert
		popupHandler.showPopup(text: "My popup is being shown")
    }
}
