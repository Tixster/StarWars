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
}
