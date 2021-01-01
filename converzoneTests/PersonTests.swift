//
//  PersonTests.swift
//  converzoneTests
//
//  Created by Goga Barabadze on 11.10.20.
//  Copyright © 2020 Goga Barabadze. All rights reserved.
//

import XCTest
@testable import converzone

class PersonTests: XCTestCase {

    func testAgeCalculationOfPersonWhoWasBornToday() {
        let personWhoWasBornToday = Person()
        personWhoWasBornToday.birthdate = Date()
        XCTAssertEqual(personWhoWasBornToday.age, 0)
    }
    
    func testAgeCalculationOfPersonWhoDoesntHaveAnAgeDefined(){
        let personWhoWasBornToday = Person()
        personWhoWasBornToday.birthdate = nil
        XCTAssertEqual(personWhoWasBornToday.age, 0)
    }

}
