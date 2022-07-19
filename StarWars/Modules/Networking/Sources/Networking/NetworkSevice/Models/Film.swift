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
    let results: [FilmResponse]
}

// MARK: - Film
public struct FilmResponse: Codable {
    public let title: String
    public let episodeID: Int
    public let openingCrawl, director, producer, releaseDate: String
    public let charactersURL, planets, starships, vehicles: [String]
    public let species: [String]
    public let created, edited: String
    public let url: String

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
