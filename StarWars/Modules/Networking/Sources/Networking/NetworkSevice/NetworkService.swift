//
//  NetworkService.swift
//  
//
//  Created by Кирилл Тила on 19.07.2022.
//

import Foundation

public protocol NetworkServiceProtocol: HTTPClient {
    func fetchAllFilms() async -> Result<[Film], HTTPRequestError>
    func fetchCharacter(at id: Int) async -> Result<CharacterResponse, HTTPRequestError>
}

public class NetwordService: NetworkServiceProtocol {
    
    public func fetchAllFilms() async -> Result<[Film], HTTPRequestError> {
        let filmsResponse = await sendRequest(endpoint: FilmsEndpoint.all,
                                              responseModel: FilmsResponse.self)
        switch filmsResponse {
        case .success(let response):
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
    
    
}
