//
//  PlanetViewModel.swift
//  StarWars
//
//  Created by Кирилл Тила on 22.07.2022.
//

import Foundation
import Networking

final class PlanetViewModel: StateMachine<PlanetViewModel.PlanetListState, PlanetViewModel.PlanetListEvent> {
    
    init(networkdService: NetworkServiceProtocol = NetwordService(), character: CharacterModel?, error: Error?) {
        self.character = character
        self.networkService = networkdService
        super.init(.initial)
        if let error = error {
            Task {
                await send(.didFetchResultsFailure(error))
            }
        }
    }
    
    // MARK: - PUBLIC VAR
    public var data: PlanetModel!
    
    // MARK: - PRIVATE VAR
    private let networkService: NetworkServiceProtocol
    private var fetchTask: Task<Void, Never>?
    private let character: CharacterModel?
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
            data = .nilMock
            stateError = nil
        case (.error, .loading):
            stateError = nil
        case
            (.loading, .error),
            (.empty, .loading):
            data = .nilMock
        default:
            fatalError("Неопределённое состояние... Из \(oldState) вы пытаетесь попасть в \(newState)")
        }
    }
    
}

private extension PlanetViewModel {
    
    func fetchPlanet() {
        guard !fetchFromCoreData() else { return }
        guard let character = character else { return }
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
                persistenceController.savePlanet(from: planetModel, for: character.name)
                await send(.didFetchResultsSuccessfully(planetModel))
            case .failure(let error):
                await send(.didFetchResultsFailure(error))
            }
        }
    }
    
    func fetchFromCoreData() -> Bool {
        guard let character = character else { return false }
        guard let planetModel = persistenceController.getPlanet(for: character.name) else { return false }
        Task {
            await send(.didFetchResultsSuccessfully(planetModel))
        }
        return true
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
