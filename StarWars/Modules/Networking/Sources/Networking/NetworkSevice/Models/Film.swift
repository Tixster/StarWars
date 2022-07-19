//
//  Film.swift
//  
//
//  Created by Кирилл Тила on 19.07.2022.
//

import Foundation

// MARK: - FilmsResponse
public struct FilmsResponse: Codable {
    let count: Int
    let results: [Film]
}

// MARK: - Film
public struct Film: Codable {
    let title: String
    let episodeID: Int
    let openingCrawl, director, producer, releaseDate: String
    let charactersURL, planets, starships, vehicles: [String]
    let species: [String]
    let created, edited: String
    let url: String

    enum CodingKeys: String, CodingKey {
        case title
        case episodeID = "episode_id"
        case openingCrawl = "opening_crawl"
        case director, producer
        case releaseDate = "release_date"
        case charactersURL = "characters"
        case planets, starships, vehicles, species, created, edited, url
    }
}
