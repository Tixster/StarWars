//
//  File.swift
//  
//
//  Created by Кирилл Тила on 19.07.2022.
//

import Foundation

public struct CharacterResponse: Codable {
    let name, height, mass, hairColor: String
    let skinColor, eyeColor, birthYear, gender: String
    let homeworld: String
    let filmsURL: [String]
    let vehicles, starships: [String]
    let created, edited: String
    let url: String

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
