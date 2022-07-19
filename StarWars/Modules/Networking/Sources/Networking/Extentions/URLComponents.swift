//
//  URLComponents.swift
//  
//
//  Created by Кирилл Тила on 19.07.2022.
//

import Foundation

extension URLComponents {
    static var `default`: Self {
        var components: Self = .init()
        components.scheme = Constants.baseScheme
        components.host = Constants.baseHost
        components.path = Constants.basePath
        return components
    }
}
