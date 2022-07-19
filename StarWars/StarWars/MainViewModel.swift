//
//  MainViewModel.swift
//  StarWars
//
//  Created by Кирилл Тила on 19.07.2022.
//

import Foundation
import Networking

final class MainViewModel: StateMachine<MainViewModel.FilmsListState, MainViewModel.FilmsListEvent>  {
    
    public var data: [Film] = []
    
    private let networkService: NetworkServiceProtocol
    
    init(networkdService: NetworkServiceProtocol = NetwordService()) {
        self.networkService = networkdService
        super.init(.initial)
    }
    
    override func handle(_ event: FilmsListEvent) -> FilmsListState? {
        switch(state, event) {
        case (.initial, .onAppear):
            fetchFilms()
            return .loading
        case (.loading, .didFetchResultsSuccessfully(let results)),
            (.results, .didFetchResultsSuccessfully(let results)):
            data = results
            return .results
        case (.loading, .didFetchResultsFailure(let error)):
            stateError = error
            return .error
        case (.loading, .didFetchResultsEmpty):
            return .empty
        case (.results, .didFetchResultsEmpty):
            break
        case (.results, .reload):
            break
        case
            (.empty, .retry),
            (.error, .retry):
            fetchFilms()
            return .loading
            
        default:
            fatalError("Event not handled...")
        }
        
        return nil
    }
    
    override func handleStateUpdate(_ oldState: FilmsListState, new newState: FilmsListState) {
        switch(oldState, newState) {
        case (.initial, .loading):
            break
        case (.loading, .results):
            break
        case (.loading, .empty):
            data = []
            stateError = nil
        case (.error, .loading):
            stateError = nil
        case
            (.loading, .error),
            (.empty, .loading):
            data = []
        default:
            fatalError("Неопределённое место... Из \(oldState) вы пытаетесь попасть в \(newState)")
        }
    }
    
}

extension MainViewModel {
    
    func fetchFilms() {
        Task {
            let result = await networkService.fetchAllFilms()
            switch result {
            case .success(let films):
                var filmsModels = films.map { film -> Film in
                    let filmModel: Film = .init(title: film.title,
                                                year: film.releaseDate,
                                                director: film.director,
                                                producer: film.producer,
                                                episode: film.episodeID,
                                                charactersURL: film.charactersURL)
                    return filmModel
                }
                filterFilms(&filmsModels)
                await send(.didFetchResultsSuccessfully(filmsModels))
            case .failure(let error):
                await send(.didFetchResultsFailure(error))
            }
        }
    }
    
    func filterFilms(_ films: inout [Film]) {
        films = films.sorted(by: { $0.episode < $1.episode })
    }
    
}

extension MainViewModel {
    enum FilmsListState: Equatable {
        case initial
        case loading
        case results
        case empty
        case error
    }
    
    enum FilmsListEvent {
        case onAppear
        
        case retry
        case reload
        case fetchNextPage
        
        case didFetchResultsSuccessfully(_ results: [Film])
        case didFetchResultsFailure(_ error: Error)
        case didFetchResultsEmpty
        
        case openFilmDetail(_ film: Film)
    }
    
}
