//
//  Film.swift
//  StarWars
//
//  Created by Кирилл Тила on 19.07.2022.
//

import Foundation

struct FilmModel: Identifiable {
    var id: String {
        return title
    }
    let title: String
    let year: String
    let director: String
    let producer: String
    let episode: Int
    let charactersURL: [String]
    
    static func convertFromCoreData(model: Film) -> Self {
        return .init(title: model.title,
                     year: model.year,
                     director: model.director,
                     producer: model.producer,
                     episode: Int(model.episode),
                     charactersURL: model.charactersURL)
    }
    
}
