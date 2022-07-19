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
    
    init(networkdService: NetworkServiceProtocol) {
        self.networkService = networkdService
        super.init(.initial)
    }
    
    override func handle(_ event: FilmsListEvent) -> FilmsListState? {
        switch event {
        case .onAppear:
            break
        case .retry:
            break
        case .reload:
            break
        case .fetchNextPage:
            break
        case .didFetchResultsFailure(let error):
            stateError = error
        case .didFetchResultsEmpty:
            break
        case .didFetchResultsSuccessfully(let films):
            data = films
        case .openFilmDetail(let film):
            break
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
                let filmsModels = films.map { film -> Film in
                    let filmModel: Film = .init(title: film.title,
                                                year: film.releaseDate,
                                                director: film.director,
                                                producer: film.producer,
                                                episode: film.episodeID,
                                                charactersURL: film.charactersURL)
                    return filmModel
                }
                send(.didFetchResultsSuccessfully(filmsModels))
            case .failure(let error):
                send(.didFetchResultsFailure(error))
            }
        }
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
