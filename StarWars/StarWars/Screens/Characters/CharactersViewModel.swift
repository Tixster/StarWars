//
//  CharactersViewModel.swift
//  StarWars
//
//  Created by Кирилл Тила on 22.07.2022.
//

import Foundation
import Networking

final class CharactersViewModel: StateMachine<CharactersViewModel.CharactersListState, CharactersViewModel.CharactersListEvent> {
    
    init(networkdService: NetworkServiceProtocol = NetwordService(), film: FilmModel) {
        self.film = film
        self.charactersURL = film.charactersURL
        self.networkService = networkdService
        super.init(.initial)
    }
    
    // MARK: - PUBLIC VAR
    public var data: [Result<CharacterModel, HTTPRequestError>] = []
    public var filmTitle: String {
        return film.title
    }
    
    // MARK: - PRIVATE VAR
    private let networkService: NetworkServiceProtocol
    private let film: FilmModel
    private let charactersURL: [String]
    private lazy var filmPredicate: NSPredicate = {
        let predicate: NSPredicate = .init(format: "%K == %@", #keyPath(Film.title), film.title)
        return predicate
    }()
    private var persistenceController: PersistenceController {
        return PersistenceController.shared
    }
    
    override func handle(_ event: CharactersListEvent) -> CharactersListState? {
        switch(state, event) {
        case (.initial, .onAppear):
            fetchCharacters()
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
            fetchCharacters()
            return .loading
        case (.results, .onAppear): break
        case (.error, .didFetchResultsFailure(let error)):
            stateError = error
            return .error
        default:
            fatalError("Event not handled... State: \(state), Event: \(event)")
        }
        
        return nil
    }
    
    override func handleStateUpdate(_ oldState: CharactersListState, new newState: CharactersListState) {
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
        case (.error, .error): break
        default:
            fatalError("Неопределённое состояние... Из \(oldState) вы пытаетесь попасть в \(newState)")
        }
    }
    
}

private extension CharactersViewModel {
    
    func fetchCharacters() {
        guard data.isEmpty else { return }
        guard !fetchFromCoreData() else { return }
        Task {
            let ids: [Int] = getIds()
            let resultResponse = await networkService.fetchCharacters(at: ids)
            var charactersModel: [CharacterModel] = []
            var resultModels = resultResponse.map { response -> Result<CharacterModel, HTTPRequestError> in
                switch response {
                case .success(let result):
                    let characterModel: CharacterModel = .init(name: result.name,
                                                               gender: result.gender,
                                                               birthYear: result.birthYear,
                                                               homeworld: result.homeworld)
                    charactersModel.append(characterModel)
                    return .success(characterModel)
                case .failure(let error):
                    return .failure(error)
                }
            }
            sort(models: &resultModels)
            persistenceController.saveCharacters(from: charactersModel, for: filmTitle)
            await send(.didFetchResultsSuccessfully(resultModels))
        }
    }
    
    func sort(models: inout [Result<CharacterModel, HTTPRequestError>]) {
        models = models.sorted(by: { first, second in
            if case .success(let firstModel) = first, case .success(let secondModel) = second {
                return firstModel.name < secondModel.name
            }
            return false
        })
    }
    
    func getIds() -> [Int] {
        var ids: [Int] = []
        charactersURL.forEach( {
            let idStr = $0.matches(for: "\\d+")[0]
            if let id = Int(idStr) {
                ids.append(id)
            }
        })
        return ids
    }
    
    func fetchFromCoreData() -> Bool {
        guard let charactersModels = persistenceController.getCharacters(for: filmTitle) else { return false }
        Task {
            var result: [Result<CharacterModel, HTTPRequestError>] = []
            charactersModels.forEach({ result.append(.success($0))})
            await send(.didFetchResultsSuccessfully(result))
        }
        return true
    }
    
}

extension CharactersViewModel {
    enum CharactersListState: Equatable {
        case initial
        case loading
        case results
        case empty
        case error
    }
    
    enum CharactersListEvent {
        case onAppear
        
        case retry
        case reload
        case fetchNextPage
        
        case didFetchResultsSuccessfully(_ results: [Result<CharacterModel, HTTPRequestError>])
        case didFetchResultsFailure(_ error: Error)
        case didFetchResultsEmpty
        
        case openFilmDetail(_ film: CharacterModel)
    }
    
}
