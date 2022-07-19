//
//  Data.swift
//  
//
//  Created by Кирилл Тила on 19.07.2022.
//

import Foundation

extension Data {
    func decode<T: Decodable>(model: T.Type) -> T? {
        return try? JSONDecoder().decode(model, from: self)
    }
}
