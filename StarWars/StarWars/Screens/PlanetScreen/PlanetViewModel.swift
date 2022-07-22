//
//  PlanetViewModel.swift
//  StarWars
//
//  Created by Кирилл Тила on 22.07.2022.
//

import Foundation
import Networking
import CoreData


final class PlanetViewModel: StateMachine<PlanetViewModel.PlanetListState, PlanetViewModel.PlanetListEvent> {
    
    init(networkdService: NetworkServiceProtocol = NetwordService(), character: CharacterModel) {
        self.character = character
        self.networkService = networkdService
        super.init(.initial)
    }
    
    public var data: PlanetModel?
    
    private let networkService: NetworkServiceProtocol
    private var fetchTask: Task<Void, Never>?
    private let character: CharacterModel
    private var persistenceController: PersistenceController {
        return PersistenceController.shared
    }
    
    override func handle(_ event: PlanetListEvent) -> PlanetListState? {
        switch(state, event) {
        case (.initial, .onAppear):
            fetchPlanet()
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
            fetchPlanet()
            return .loading
        case (.results, .onAppear): break
        default:
            fatalError("Event not handled...")
        }
        
        return nil
    }
    
    override func handleStateUpdate(_ oldState: PlanetListState, new newState: PlanetListState) {
        switch(oldState, newState) {
        case (.initial, .loading):
            break
        case (.loading, .results):
            break
        case (.loading, .empty):
            data = nil
            stateError = nil
        case (.error, .loading):
            stateError = nil
        case
            (.loading, .error),
            (.empty, .loading):
            data = nil
        default:
            fatalError("Неопределённое состояние... Из \(oldState) вы пытаетесь попасть в \(newState)")
        }
    }
    
}

private extension PlanetViewModel {
    
    func fetchPlanet() {
        guard !fetchFromCoreData() else { return }
        let idStr = character.homeworld.matches(for: "\\d+").first!
        guard let id = Int(idStr) else { return }
        Task {
            let planetResult = await networkService.fetchPlanet(at: id)
            switch planetResult {
            case .success(let result):
                let planetModel: PlanetModel = .init(name: result.name,
                                                     diameter: result.diameter,
                                                     climate: result.climate,
                                                     gravity: result.gravity,
                                                     terrain: result.terrain,
                                                     population: result.population)
                do {
                    let planetContext: Planet = .init(context: persistenceController.container.viewContext)
                    planetContext.name = result.name
                    planetContext.diameter = result.diameter
                    planetContext.climate = result.climate
                    planetContext.gravity = result.gravity
                    planetContext.terrain = result.terrain
                    planetContext.population = result.population
                    let fetchReques: NSFetchRequest = Character.fetchRequest()
                    let predicate: NSPredicate = .init(format: "%K == %@", #keyPath(Character.name), character.name)
                    fetchReques.predicate = predicate
                    let character: Character = try persistenceController.container.viewContext.fetch(fetchReques).first!
                    character.characterToHomeworld = planetContext
                    planetContext.addToHomeworldToCharacter(character)
                } catch {
                    print(error.localizedDescription)
                }
                await send(.didFetchResultsSuccessfully(planetModel))
            case .failure(let error):
                await send(.didFetchResultsFailure(error))
            }
        }
    }
    
    func fetchFromCoreData() -> Bool {
        let fetchRequest: NSFetchRequest = Planet.fetchRequest()
        let predicate: NSPredicate = .init(format: "ANY homeworldToCharacter.name = %@", character.name)
        fetchRequest.predicate = predicate
        do {
            let planets = try persistenceController.container.viewContext.fetch(fetchRequest)
            if planets.isEmpty {
                return false
            } else {
                let planetModel: PlanetModel = .convertFromCoreData(model: planets.first!)
                Task {
                    await send(.didFetchResultsSuccessfully(planetModel))
                }
                return true
            }
        } catch let error as NSError {
            print("Cloud not fetch: \(error), \(error.userInfo)")
            return false
        }
    }
    
    
}

extension PlanetViewModel {
    enum PlanetListState: Equatable {
        case initial
        case loading
        case results
        case empty
        case error
    }
    
    enum PlanetListEvent {
        case onAppear
        
        case retry
        case reload
        case fetchNextPage
        
        case didFetchResultsSuccessfully(_ results: PlanetModel)
        case didFetchResultsFailure(_ error: Error)
        case didFetchResultsEmpty
    }
}
