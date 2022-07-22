//
//  File.swift
//  
//
//  Created by Кирилл Тила on 19.07.2022.
//

import Foundation

public struct CharacterResponse: Codable {
    public let name, height, mass, hairColor: String
    public let skinColor, eyeColor, birthYear, gender: String
    public let homeworld: String
    public let filmsURL: [String]
    public let vehicles, starships: [String]
    public let created, edited: String
    public let url: String

    enum CodingKeys: String, CodingKey {
        case name, height, mass
        case hairColor = "hair_color"
        case skinColor = "skin_color"
        case eyeColor = "eye_color"
        case birthYear = "birth_year"
        case gender, homeworld, vehicles, starships, created, edited, url
        case filmsURL = "films"
    }
}
