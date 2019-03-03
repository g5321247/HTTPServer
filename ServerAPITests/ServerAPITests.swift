//
//  ServerAPITests.swift
//  ServerAPITests
//
//  Created by George Liu on 2019/3/3.
//  Copyright © 2019 George Liu. All rights reserved.
//

import XCTest
@testable import ServerAPI

class ServerAPITests: XCTestCase {

    var server: HTTPServer!
    let session = MockURLSession()
    
    override func setUp() {
        server = HTTPServer(session: session)
    }

    override func tearDown() {
        server = nil
    }
    
    func test_Request_RequestURL() {
        let url = URL(string: "www.google.com")!
        server.request(url: url) {_,_ in }
        
        XCTAssert(session.request!.url == url)
    }
    
    func test_Request_RequestMethod() {
        let url = URL(string: "www.google.com")!
        server.request(url: url, method: .get) {_,_ in }
        
        XCTAssert(session.request!.httpMethod == APIMethod.get.rawValue)
    }
    
    func test_Request_StartRequest() {
        let url = URL(string: "www.google.com")!
        server.request(url: url) {_,_ in }
        
        XCTAssertTrue(session.nextDataTask.isCalled)
    }
    
    // Data
    func test_Request_ReturnVaildData() {
        let url = URL(string: "www.google.com")!
        let expectedData = "{}".data(using: String.Encoding.utf8)
        session.nextResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        session.nextData = expectedData
        
        var acutalData: Data?
        
        server.request(url: url) { data, _ in
            acutalData = data
        }
        
        XCTAssert(acutalData == expectedData)
    }
    
    func test_Request_InvalidData() {
        let url = URL(string: "www.google.com")!
        session.nextResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        session.nextData = nil
        
        var actualError: NetworkError?
        
        server.request(url: url) { _, error in
            actualError = error as? NetworkError
        }
        XCTAssert(actualError! == NetworkError.invalidData)
    }

    // Error
    func test_Request_ReturnError() {
        let url = URL(string: "www.google.com")!
        let expectedError = NSError(domain: "error", code: 0, userInfo: nil)
        session.nextError = expectedError
        
        server.request(url: url) { _, error in
            XCTAssert(error! as NSError == expectedError)
        }
    }
    
    // Response
    func test_Request_ResponseLesserThan200() {
        let url = URL(string: "www.google.com")!
        session.nextResponse = HTTPURLResponse(statusCode: 199)
        
        var actualError: NetworkError?
        
        server.request(url: url) { _, error in
            actualError = error as? NetworkError
        }
        XCTAssert(actualError! == NetworkError.responseUnsuccessful(statusCode: 199))
    }
    
    func test_Request_ResponseGreaterThan300() {
        let url = URL(string: "www.google.com")!
        session.nextResponse = HTTPURLResponse(statusCode: 300)
        var actualError: NetworkError?
        
        server.request(url: url) { _, error in
            actualError = error as? NetworkError
        }
        XCTAssert(actualError! == NetworkError.responseUnsuccessful(statusCode: 300))
    }
    
    func test_Request_RequestFail() {
        let url = URL(string: "www.google.com")!
        session.nextResponse = nil
        var actualError: NetworkError?
        
        server.request(url: url) { _, error in
            actualError = error as? NetworkError
        }
        XCTAssert(actualError! == NetworkError.requestFailed)
    }

}
