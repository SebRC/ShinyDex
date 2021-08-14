//
//  MoveServiceTests.swift
//  ShinyDexTests
//
//  Created by Sebastian Christiansen on 14/08/2021.
//  Copyright © 2021 Sebastian Christiansen. All rights reserved.
//

import XCTest
@testable import ShinyDex

class MoveServiceTests: XCTestCase {
    var moveService: MoveService!

    override func setUpWithError() throws {
        try super.setUpWithError()
        moveService = MoveService()
    }

    override func tearDownWithError() throws {
        moveService = nil
        try super.tearDownWithError()
    }

    func test_saveActiveMoves_valuesAreSaved() throws {
        // Arrange
        let activeMoves = moveService.getAll()
        let activeMove = activeMoves[0]
        activeMove.name = "Fire blast"
        activeMove.remainingPP = 11
        activeMove.maxPP = 5
        activeMove.type = "Fire"

        // Act
        moveService.save(activeMoves: activeMoves, pressureActive: true)
        let updatedMove = moveService.getAll()[0]
        let pressureActive = moveService.getIsPressureActive()

        // Assert
        XCTAssertEqual(updatedMove.name, activeMove.name)
        XCTAssertEqual(updatedMove.maxPP, activeMove.maxPP)
        XCTAssertEqual(updatedMove.remainingPP, activeMove.remainingPP)
        XCTAssertEqual(updatedMove.type, activeMove.type)
        XCTAssertEqual(pressureActive, true)
    }
}
