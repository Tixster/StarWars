//
//  Endpoint.swift
//  
//
//  Created by Кирилл Тила on 19.07.2022.
//

import Foundation

public protocol Endpoint {
    var url: URL? { get }
    var queryItems: [URLQueryItem]? { get }
    var path: String { get }
    var method: HTTPRequestMethods { get }
    var header: [String: String]? { get }
    var body: [String: String]? { get }
}
