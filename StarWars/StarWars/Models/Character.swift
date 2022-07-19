//
//  Character.swift
//  StarWars
//
//  Created by Кирилл Тила on 19.07.2022.
//

import Foundation

struct Character: Identifiable {
    var id: String {
        return name
    }
    let name: String
    let gender: String
    let birthYear: String
    let homeworld: String
}
