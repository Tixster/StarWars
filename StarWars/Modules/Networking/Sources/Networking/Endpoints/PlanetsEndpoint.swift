//
//  PlanetsEndpoint.swift
//  
//
//  Created by Кирилл Тила on 19.07.2022.
//

import Foundation

public enum PlanetsEndpoint {
    case planet(id: Int)
}

extension PlanetsEndpoint: Endpoint {
    public var url: URL? {
        var components: URLComponents = .default
        components.queryItems = queryItems
        components.path += "/planets" + path
        return components.url
    }
    
    public var queryItems: [URLQueryItem]? {
        switch self {
        case .planet: return nil
        }
    }
    
    public var path: String {
        switch self {
        case .planet(let id): return "/\(id)"
        }
    }
    
    public var method: HTTPRequestMethods {
        switch self {
        case .planet: return .get
        }
    }
    
    public var header: [String : String]? {
        switch self {
        case .planet: return nil
        }
    }
    
    public var body: [String : String]? {
        switch self {
        case .planet: return nil
        }
    }
    
    
}
