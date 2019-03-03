//
//  Server.swift
//  ServerAPI
//
//  Created by George Liu on 2019/3/3.
//  Copyright © 2019 George Liu. All rights reserved.
//

import Foundation

enum NetworkError: Error, Equatable {
    case requestFailed
    case responseUnsuccessful(statusCode: Int)
    case invalidData
    case jsonParsingFailure
    case invalidUrl
}

enum APIMethod: String {
    case none
    case post = "POST"
    case get = "GET"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

class HTTPServer {
    
    typealias CompletionHandler = (Data?, Error?) -> Void
    private let session: SessionProtocol
    
    init(session: SessionProtocol = URLSession.shared) {
        self.session = session
    }
    
    func request(url: URL, method: APIMethod = .none, compltionHandler: @escaping CompletionHandler) {
        var request = URLRequest(url: url)
        method != .none ? request.httpMethod = method.rawValue : nil
        
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            
            guard error == nil else {
                compltionHandler(nil, error!)
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                compltionHandler(nil, NetworkError.requestFailed)
                return
            }
            
            guard 200 ... 299 ~= response.statusCode else {
                compltionHandler(nil, NetworkError.responseUnsuccessful(statusCode: response.statusCode))
                return
            }
            
            guard data != nil else {
                compltionHandler(nil, NetworkError.invalidData)
                return
            }
            
            compltionHandler(data, nil)
        }
        
        dataTask.resume()
    }
}
