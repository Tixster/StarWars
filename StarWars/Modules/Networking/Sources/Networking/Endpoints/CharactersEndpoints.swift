//
//  CharactersEndpoints.swift
//  
//
//  Created by Кирилл Тила on 19.07.2022.
//

import Foundation

public enum CharactersEndpoints {
    case character(id: Int)
}

extension CharactersEndpoints: Endpoint {
    public var url: URL? {
        var components: URLComponents = .default
        components.queryItems = queryItems
        components.path += "/people" + path
        return components.url
    }
    
    public var queryItems: [URLQueryItem]? {
        switch self {
        case .character: return nil
        }
    }
    
    public var path: String {
        switch self {
        case .character(let id):
            return "/\(id)"
        }
    }
    
    public var method: HTTPRequestMethods {
        switch self {
        case .character: return .get
        }
    }
    
    public var header: [String : String]? {
        switch self {
        case .character: return nil
        }
    }
    
    public var body: [String : String]? {
        switch self {
        case .character: return nil
        }
    }
    
    
}
