//
//  MainViewModel.swift
//  StarWars
//
//  Created by Кирилл Тила on 19.07.2022.
//

import Foundation
import Networking
import CoreData

final class MainViewModel: StateMachine<MainViewModel.FilmsListState, MainViewModel.FilmsListEvent>  {

    init(networkdService: NetworkServiceProtocol = NetwordService()) {
        self.networkService = networkdService
        super.init(.initial)
    }
    
    public var data: [FilmModel] = []
    public let networkService: NetworkServiceProtocol

    private var persistenceController: PersistenceController {
        return PersistenceController.shared
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
        case (.results, .onAppear): break
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
            fatalError("Неопределённое состояние... Из \(oldState) вы пытаетесь попасть в \(newState)")
        }
    }
    
}

private extension MainViewModel {
    
    func fetchFilms() {
        guard !fetchFromCoreData() else { return }
        Task {
            let result = await networkService.fetchAllFilms()
            switch result {
            case .success(let films):
                var filmsModels = films.map { film -> FilmModel in
                    let filmModel: FilmModel = .init(title: film.title,
                                                year: film.releaseDate,
                                                director: film.director,
                                                producer: film.producer,
                                                episode: film.episodeID,
                                                charactersURL: film.charactersURL)
                    let filmsContext: Film = .init(context: persistenceController.container.viewContext)
                    filmsContext.title = film.title
                    filmsContext.year = film.releaseDate
                    filmsContext.director = film.director
                    filmsContext.producer = film.producer
                    filmsContext.episode = Int16(film.episodeID)
                    filmsContext.charactersURL = film.charactersURL
                    return filmModel
                }
                persistenceController.save()
                filterFilms(&filmsModels)
                await send(.didFetchResultsSuccessfully(filmsModels))
            case .failure(let error):
                await send(.didFetchResultsFailure(error))
            }
        }
    }
    
    func filterFilms(_ films: inout [FilmModel]) {
        films = films.sorted(by: { $0.episode < $1.episode })
    }
    
    func fetchFromCoreData() -> Bool {
        let fetchRequest: NSFetchRequest = Film.fetchRequest()
        let sort: NSSortDescriptor = .init(key: #keyPath(Film.episode), ascending: true)
        fetchRequest.sortDescriptors = [sort]
        do {
            let films = try persistenceController.container.viewContext.fetch(fetchRequest)
            let filmsModel = films.map({ return FilmModel.convertFromCoreData(model: $0) })
            if films.isEmpty {
                return false
            } else {
                Task {
                    print(filmsModel)
                    await send(.didFetchResultsSuccessfully(filmsModel))
                }
                return true
            }
        } catch let error as NSError {
            print("Cloud not fetch: \(error), \(error.userInfo)")
            return false
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
        
        case didFetchResultsSuccessfully(_ results: [FilmModel])
        case didFetchResultsFailure(_ error: Error)
        case didFetchResultsEmpty
        
        case openFilmDetail(_ film: FilmModel)
    }
    
}
