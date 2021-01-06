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

    func testStringToGenderConversion() {
        let inputs = ["any", "ANY", "anY", "all", "f", "female", "m", "male", "", " ", "anything else"]
        let correctOutputs: [Gender] = [.any, .any, .any, .any, .female, .female, .male, .male, .unknown, .unknown, .non_binary]
        
        for (input, output) in zip(inputs, correctOutputs) {
            XCTAssertEqual(Gender.toGender(gender: input), output)
        }
    }
    
    func testGenderToStringConversion() {
        let inputs: [Gender] = [.any, .female, .male, .non_binary, .unknown]
        let correctOutputs = ["any", "female", "male", "non binary", ""]
        
        for (input, output) in zip(inputs, correctOutputs){
            XCTAssertEqual(input.toString(), output)
        }
    }
    
    func testUnopenedChatsCount(){
        
        let master = Master()
        
        for i in 1...10000 {
            let user = User()
            
            let message1 = Message()
            message1.opened = true
            
            let message2 = Message()
            message2.opened = i % 2 == 0
            
            if arc4random() % 2 == 0 {
                user.conversation.append(message1)
            }
            
            user.conversation.append(message2)
            
            master.conversations.append(user)
        }
        
        XCTAssertEqual(master.unopened_chats, 5000)
    }
    
    func testCompareTwoUsers() {
        
        XCTAssert(User() == User())
        
        let user1 = User()
        let user2 = User()
        
        user1.uid = "1"
        
        XCTAssertFalse(user1 == user2)
        
        user1.uid = ""
        
        XCTAssert(user1 == user2)
    }
    
}
