//
//  Film.swift
//  StarWars
//
//  Created by Кирилл Тила on 19.07.2022.
//

import Foundation

struct Film: Identifiable {
    var id: String {
        return title
    }
    let title: String
    let year: String
    let director: String
    let producer: String
    let episode: Int
    let charactersURL: [String]
}
