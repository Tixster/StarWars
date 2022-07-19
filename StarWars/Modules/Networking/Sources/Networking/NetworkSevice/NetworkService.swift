//
//  NetworkService.swift
//  
//
//  Created by Кирилл Тила on 19.07.2022.
//

import Foundation

public protocol NetworkServiceProtocol: HTTPClient {
    func fetchAllFilms() async -> Result<[FilmResponse], HTTPRequestError>
    func fetchCharacter(at id: Int) async -> Result<CharacterResponse, HTTPRequestError>
    func fetchPlanet(at id: Int) async -> Result<PlanetResponse, HTTPRequestError>
}

public class NetwordService: NetworkServiceProtocol {
    
    public init() {}
    
    public func fetchAllFilms() async -> Result<[FilmResponse], HTTPRequestError> {
        let filmsResponse = await sendRequest(endpoint: FilmsEndpoint.all,
                                              responseModel: FilmsResponse.self)
        switch filmsResponse {
        case .success(let response):
            #if DEBUG
            print(response.results)
            #endif
            return .success(response.results)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    public func fetchCharacter(at id: Int) async -> Result<CharacterResponse, HTTPRequestError> {
        let characterResponse = await sendRequest(endpoint: CharactersEndpoints.character(id: id),
                                                  responseModel: CharacterResponse.self)
        return characterResponse
    }
    
    public func fetchPlanet(at id: Int) async -> Result<PlanetResponse, HTTPRequestError> {
        let planetResponse = await sendRequest(endpoint: PlanetsEndpoint.planet(id: id),
                                                  responseModel: PlanetResponse.self)
        return planetResponse
    }
    
}
