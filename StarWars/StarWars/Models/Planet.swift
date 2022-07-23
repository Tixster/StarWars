//
//  Planet.swift
//  StarWars
//
//  Created by Кирилл Тила on 19.07.2022.
//

import Foundation

struct PlanetModel: Identifiable {
    var id: String {
        return name
    }
    let name: String
    let diameter: String
    let climate: String
    let gravity: String
    let terrain: String
    let population: String
    
    static func convertFromCoreData(model: Planet) -> Self {
        return .init(name: model.name,
                     diameter: model.diameter,
                     climate: model.climate,
                     gravity: model.gravity,
                     terrain: model.terrain,
                     population: model.population)
    }
    
    static var nilMock: Self {
        return .init(name: "nil",
                     diameter: "nil",
                     climate: "nil",
                     gravity: "nil",
                     terrain: "nil",
                     population: "nil")
    }
    
}
