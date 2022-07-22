//
//  Planet.swift
//  
//
//  Created by Кирилл Тила on 19.07.2022.
//

import Foundation

public struct PlanetResponse: Codable {
    public let name, rotationPeriod, orbitalPeriod, diameter: String
    public let climate, gravity, terrain, surfaceWater: String
    public let population: String
    public let residents, films: [String]
    public let created, edited: String
    public let url: String

    enum CodingKeys: String, CodingKey {
        case name
        case rotationPeriod = "rotation_period"
        case orbitalPeriod = "orbital_period"
        case diameter, climate, gravity, terrain
        case surfaceWater = "surface_water"
        case population, residents, films, created, edited, url
    }
}
