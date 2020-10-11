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

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

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

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
