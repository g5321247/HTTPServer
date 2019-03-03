//
//  URLSession.swift
//  ServerAPI
//
//  Created by George Liu on 2019/3/3.
//  Copyright © 2019 George Liu. All rights reserved.
//

import Foundation

protocol SessionProtocol {
    typealias CompletionHandler = (Data?, URLResponse?, Error?) -> Void
    func dataTask(with request: URLRequest, completionHandler: @escaping CompletionHandler) -> URLSessionDataTaskProtocol
}

extension URLSession: SessionProtocol {
    func dataTask(with request: URLRequest, completionHandler: @escaping CompletionHandler) -> URLSessionDataTaskProtocol {
        return dataTask(with: request, completionHandler: completionHandler) as URLSessionDataTask
    }
}

class MockURLSession: SessionProtocol {
    
    let nextDataTask = MockURLSessionDataTask()    
    private(set)var request: URLRequest?
    var nextData: Data?
    var nextError: Error?
    var nextResponse: HTTPURLResponse?
    
    func dataTask(with request: URLRequest, completionHandler: @escaping CompletionHandler) -> URLSessionDataTaskProtocol {
        
        self.request = request
        
        completionHandler(nextData, nextResponse, nextError)
        
        return nextDataTask
    }
}


protocol URLSessionDataTaskProtocol {
    func resume()
}

extension URLSessionDataTask: URLSessionDataTaskProtocol {}

class MockURLSessionDataTask: URLSessionDataTaskProtocol {
    
    private(set) var isCalled: Bool = false
    
    func resume() {
        isCalled = true
    }
}

extension HTTPURLResponse {
    convenience init?(statusCode: Int) {
        self.init(url: NSURL() as URL, statusCode: statusCode, httpVersion: nil, headerFields: nil)
    }
}
