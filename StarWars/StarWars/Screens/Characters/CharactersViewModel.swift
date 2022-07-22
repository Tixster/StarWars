//
//  CharactersViewModel.swift
//  StarWars
//
//  Created by Кирилл Тила on 22.07.2022.
//

import Foundation
import Networking
import CoreData

final class CharactersViewModel: StateMachine<CharactersViewModel.CharactersListState, CharactersViewModel.CharactersListEvent> {
    
    init(networkdService: NetworkServiceProtocol = NetwordService(), film: FilmModel) {
        self.film = film
        self.charactersURL = film.charactersURL
        self.networkService = networkdService
        super.init(.initial)
    }
    
    public var data: [Result<CharacterModel, HTTPRequestError>] = []
    
    private let networkService: NetworkServiceProtocol
    private var fetchTask: Task<Void, Never>?
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
        fetchTask = Task {
            var ids: [Int] = []
            charactersURL.forEach( {
                let idStr = $0.matches(for: "\\d+")[0]
                if let id = Int(idStr) {
                    ids.append(id)
                }
            })
            let resultResponse = await networkService.fetchCharacters(at: ids)
            let resultModel = resultResponse.map { response -> Result<CharacterModel, HTTPRequestError> in
                switch response {
                case .success(let result):
                    let characterModel: CharacterModel = .init(name: result.name,
                                                               gender: result.gender,
                                                               birthYear: result.birthYear,
                                                               homeworld: result.homeworld)
                    let characterContext: Character = .init(context: persistenceController.container.viewContext)
                    do {
                        let fetchRequest: NSFetchRequest = Film.fetchRequest()
                        fetchRequest.predicate = filmPredicate
                        let films = try persistenceController.container.viewContext.fetch(fetchRequest)
                        let film = films.first!
                        characterContext.name = result.name
                        characterContext.gender = result.gender
                        characterContext.birthYear = result.birthYear
                        characterContext.homeWorldURL = result.homeworld
                        characterContext.addToCharacterToFilm(film)
                        film.addToFilmToCharaters(characterContext)
                    } catch {
                        print(error.localizedDescription)
                    }
                    return .success(characterModel)
                case .failure(let error):
                    return .failure(error)
                }
            }
            persistenceController.save()
            await send(.didFetchResultsSuccessfully(resultModel))
        }
    }
    
    func fetchFromCoreData() -> Bool {
        let fetchRequest: NSFetchRequest = Character.fetchRequest()
        let predicate: NSPredicate = .init(format: "ANY characterToFilm.title = %@", film.title)
        fetchRequest.predicate = predicate
        do {
            let characters = try persistenceController.container.viewContext.fetch(fetchRequest)
            let charactersModels = characters.map({ return CharacterModel.convertFromCoreData(model: $0) })
            if characters.isEmpty {
                return false
            } else {
                Task {
                    print(charactersModels)
                    var result: [Result<CharacterModel, HTTPRequestError>] = []
                    charactersModels.forEach({ result.append(.success($0))})
                    await send(.didFetchResultsSuccessfully(result))
                }
                return true
            }
        } catch let error as NSError {
            print("Cloud not fetch: \(error), \(error.userInfo)")
            return false
        }
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
