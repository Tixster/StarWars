//
//  FilmsEndpoint.swift
//  
//
//  Created by Кирилл Тила on 19.07.2022.
//

import Foundation

public enum FilmsEndpoint {
    case all
    case film(id: Int)
}

extension FilmsEndpoint: Endpoint {
    public var url: URL? {
        var components: URLComponents = .default
        components.queryItems = queryItems
        components.path += "/films" + path
        return components.url
    }
    
    public var queryItems: [URLQueryItem]? {
        switch self {
        case .all: return nil
        case .film: return nil
        }
    }
    
    public var path: String {
        switch self {
        case .all: return ""
        case .film(let id): return "/\(id)"
        }
    }
    
    public var method: HTTPRequestMethods {
        switch self {
        case .all: return .get
        case .film: return .get
        }
    }
    
    public var header: [String : String]? {
        switch self {
        case .all: return nil
        case .film: return nil
        }
    }
    
    public var body: [String : String]? {
        switch self {
        case .all: return nil
        case .film: return nil
        }
    }
    
    
}
