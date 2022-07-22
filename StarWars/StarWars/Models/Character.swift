//
//  Character.swift
//  StarWars
//
//  Created by Кирилл Тила on 19.07.2022.
//

import Foundation

struct CharacterModel: Identifiable {
    var id: String {
        return name
    }
    let name: String
    let gender: String
    let birthYear: String
    let homeworld: String
    
    static func convertFromCoreData(model: Character) -> Self {
        return .init(name: model.name,
                     gender: model.gender,
                     birthYear: model.birthYear,
                     homeworld: model.homeWorldURL)
    }
    
}
