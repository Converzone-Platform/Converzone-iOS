//
//  WorldTests.swift
//  converzoneTests
//
//  Created by Goga Barabadze on 01.01.21.
//  Copyright © 2021 Goga Barabadze. All rights reserved.
//

import XCTest
@testable import converzone

class WorldTests: XCTestCase {

    var world: World!
    
    override func setUpWithError() throws {
        world = World(name: "Earth")
    }

    override func tearDownWithError() throws {
        world = nil
    }
    
    func testCountOfContinents() {
        XCTAssertEqual(world.continents.count, 6)
    }
    
    func testCountCountriesInContinents(){
        XCTAssertEqual(countries_africa.count, 54)
        XCTAssertEqual(countries_asia.count, 49)
        XCTAssertEqual(countries_australia_and_oceania.count, 14)
        XCTAssertEqual(countries_europe.count, 51)
        XCTAssertEqual(countries_north_america.count, 23)
        XCTAssertEqual(countries_south_america.count, 12)
    }
    
    func testGetCountriesOfContinent(){
        XCTAssertEqual(world.getCountriesOf("Africa").count, 54)
        XCTAssertEqual(world.getCountriesOf("Asia").count, 49)
        XCTAssertEqual(world.getCountriesOf("Australia and Oceania").count, 14)
        XCTAssertEqual(world.getCountriesOf("Europe").count, 51)
        XCTAssertEqual(world.getCountriesOf("North America").count, 23)
        XCTAssertEqual(world.getCountriesOf("South America").count, 12)
    }
    
    func testCountLanguages(){
        XCTAssertEqual(all_languages.count, 500)
    }
    
    func testCompareLanguages(){
        XCTAssertEqual(Language(name: ""), Language(name: ""))
        XCTAssertNotEqual(Language(name: "1"), Language(name: "2"))
    }
    
    func testCountryNameForCountryCodeEnglishUS(){
        let inputs = ["fr", "de", "gb"]
        let correctOutput = ["France", "Germany", "United Kingdom"]
        
        for (input, output) in zip(inputs, correctOutput) {
            XCTAssertEqual(Country.countryName(countryCode: input), output)
        }
    }
    
    func testCountryNameForCountryCodeGermanAustria(){
        let inputs = ["fr", "de", "gb"]
        let correctOutput = ["Frankreich", "Deutschland", "Vereinigtes Königreich"]
        
        for (input, output) in zip(inputs, correctOutput) {
            XCTAssertEqual(Country.countryName(countryCode: input, with: "de_AT"), output)
        }
    }
    
    func testCountryNameForCountryCodeGeorgianGeorgia(){
        let inputs = ["fr", "de", "gb"]
        let correctOutput = ["საფრანგეთი", "გერმანია", "გაერთიანებული სამეფო"]
        
        for (input, output) in zip(inputs, correctOutput) {
            XCTAssertEqual(Country.countryName(countryCode: input, with: "geo_GE"), output)
        }
    }
    
    func testCountryNameForCountryCodeNil(){
        let inputs = ["baba", "dede", "rrr"]
        
        for input in inputs {
            XCTAssertNil(Country.countryName(countryCode: input))
        }
    }
    
    func testSortLanguages() {
        
        XCTAssertEqual(world.languages.first?.name, "Abaza")
        XCTAssertEqual(world.languages.last?.name, "Binary")
        
        world.sort()
        
        XCTAssertEqual(world.languages.first?.name, "Abaza")
        XCTAssertEqual(world.languages.last?.name, "Zuñi")
    }
}
