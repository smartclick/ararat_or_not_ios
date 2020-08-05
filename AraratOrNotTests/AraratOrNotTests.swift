//
//  AraratOrNotTests.swift
//  AraratOrNotTests
//
//  Created by Sevak Soghoyan on 8/4/20.
//  Copyright © 2020 Sevak Soghoyan. All rights reserved.
//

import XCTest
@testable import AraratOrNot

class AraratOrNotTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testDetectAraratWithLink() {
        let imageLink = "https://d31qtdfy11mjj9.cloudfront.net/articles/90/the-ararat-mountain.jpg"
        let exp = expectation(description: "Checking if there is Ararat in this image Link")
        AraratOrNot.detectAraratOrNot(withImageLinkPath: imageLink) { (result) in
            switch result {
            case .failure(let networkError):
                XCTAssertNotNil(networkError)
            case .success(let imResponse):
                XCTAssertNotNil(imResponse.id)
                XCTAssertNotNil(imResponse.probability)
            }
            exp.fulfill()
        }
        
        
        
        let brokenExp = expectation(description: "Checking brokenImageLink")
        AraratOrNot.detectAraratOrNot(withImageLinkPath: "") { (result) in
            switch result {
            case .failure(let networkError):
                XCTAssertNotNil(networkError)
            case .success(let imResponse):
                XCTAssertNotNil(imResponse.id)
                XCTAssertNotNil(imResponse.probability)
            }
            brokenExp.fulfill()
        }
        
        
        waitForExpectations(timeout: 10) { (error) in
            print(error?.localizedDescription ?? "error")
        }
        
    }
    
    func testDetectAraratWithImage() {        
        let exp = expectation(description: "Checking if there is Ararat in this image")
        AraratOrNot.detectAraratOrNot(withImageData: Data()) { (result) in
            switch result {
            case .failure(let networkError):
                XCTAssertNotNil(networkError)
            case .success(let imResponse):
                XCTAssertNotNil(imResponse.id)
                XCTAssertNotNil(imResponse.probability)
            }
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 10) { (error) in
            print(error?.localizedDescription ?? "error")
        }
        
    }
    
    func testSendFeedback() {
        let correctexp = expectation(description: "Checking if works send feedback api")
        let image_id = "49c9a300-c0fa-42b3-89c5-25b9be2e86aa"
        AraratOrNot.sendFeedback(withImageID: image_id, isCorrect: true) { (result) in
            switch result {
            case .failure(let networkError):
                XCTAssertNotNil(networkError)
            case .success(let imResponse):
                XCTAssertNotNil(imResponse.message)
            }
            correctexp.fulfill()
        }
        
        let notCorrectexp = expectation(description: "Checking if works send feedback api")
        let broken_image_id = ""
        AraratOrNot.sendFeedback(withImageID: broken_image_id, isCorrect: false) { (result) in
            switch result {
            case .failure(let networkError):
                XCTAssertNotNil(networkError)
            case .success(let imResponse):
                XCTAssertNotNil(imResponse.message)
            }
            notCorrectexp.fulfill()
        }
        
        waitForExpectations(timeout: 10) { (error) in
            print(error?.localizedDescription ?? "error")
        }
        
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
